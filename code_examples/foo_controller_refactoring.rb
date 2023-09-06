# BEFORE

module Admin::Onboards
  class FooController < Admin::BaseController

    def find_and_check_business
      # base_url = params.fetch(:base_url)
      # username = params.fetch(:username, nil)
      # password = params.fetch(:password, nil)
      client_id = params.fetch(:client_id, nil)
      client_secret = params.fetch(:client_secret, nil)
      group_activation_code = params.fetch(:group_activation_code, nil)
      test_mode = params.fetch(:test_mode, nil)

      foo_integrations = Foo::Integration.all # <- unnecessary .all call

      integration = foo_integrations.detect do |item| # <- parsing all integrations
        # item.configuration[:base_url].eql?(base_url) &&
        #   item.configuration[:username].eql?(username) &&
        #   item.configuration[:password].eql?(password) &&
          item.configuration[:client_id].eql?(client_id) &&
          item.configuration[:client_secret].eql?(client_secret) &&
          item.configuration[:group_activation_code].eql?(group_activation_code) &&
          item.configuration[:test_mode].eql?(test_mode)
      end

      integration ||= Foo::Integration.new(configuration: {
        # base_url: base_url,
        # username: username,
        # password: password,
        client_id: client_id,
        client_secret: client_secret,
        group_activation_code: group_activation_code,
        test_mode: test_mode
      })

      business = Business.find_or_create_by(name: 'Foo', external_name: 'Foo') # <- require transaction
      integration.business = business
      integration.ends_at = nil
      integration.save

      render json: { integration: integration.as_json(include: [:business]) }, status: :ok

    rescue Net::OpenTimeout, Foo::Exceptions::ApiFailed => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def synchronize
      integration_id = params.fetch(:integration_id)
      if Foo::Integration.where(id: integration_id).exists?
        SynchronizeIntegration.perform_async(integration_id)
        head :ok
      else
        render json: { error: 'Integration not found' }, status: :unprocessable_entity
      end
    end
  end
end


# AFTER

# frozen_string_literal: true

module Admin::Onboards
  class FooController < Admin::BaseController
    # added API check to ensure credentials are valid
    def regions
      api = Foo::ApiV2.new(params[:client_id], params[:client_secret], params[:test_mode])
      regions = api.regions

      render json: { regions: regions }, status: :ok
    rescue OAuth2::Error => e
      render json: { error: e.message }, status: :unprocessable_entity
    end

    def create
      # added manager to move business logic out of controller
      business = Foo::OnboardingManager.new.onboard(params)

      if business
        render json: { business: business, integrations: business.integrations }, status: :ok
      else
        render json: { error: 'Bad Request' }, status: :bad_request
      end
    end

    def synchronize
      integration_ids = params.fetch(:integration_ids)

      integrations = Foo::Integration.where(id: integration_ids)

      if integrations.count < integration_ids.count
        render json: { error: 'Integration not found' }, status: :not_found
        return
      end

      integrations.find_each do |integration|
        SynchronizeIntegration.perform_async(integration.id)
      end

      head :ok
    end
  end
end

# frozen_string_literal: true

module Foo
  class OnboardingManager
    def onboard(params)
      client_id = params.fetch(:client_id)
      client_secret = params.fetch(:client_secret)
      group_activation_code = params.fetch(:group_activation_code)
      test_mode = params.fetch(:test_mode)
      region_ids = params.fetch(:region_ids)

      business = Business.joins(:integrations)
                         .where(integrations: { external_business_id: region_ids })
                         .first_or_initialize(
                            name: "Foo-#{client_id}",
                            external_name: 'Foo'
                          )

      Business.transaction do
        business.save!

        region_ids.each do |rid|
          integration = Integration.where(type: 'Foo::Integration', external_business_id: rid).first_or_initialize(
            business: business,
            configuration: {
              client_id: client_id,
              client_secret: client_secret,
              group_activation_code: group_activation_code,
              test_mode: test_mode
            }
          )
          integration.save!
        end
      end

      business
    rescue KeyError
      nil
    end
  end
end
