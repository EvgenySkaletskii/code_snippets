# frozen_string_literal: true

ActiveAdmin.register BtbTier, as: 'B2b Tier' do
  menu parent: 'Fit Reserve'

  config.filters = false

  controller do
    def create
      super do |success, _failure|
        success.html { redirect_to collection_path }
      end
    end

    def update
      super do |success, _failure|
        success.html { redirect_to collection_path }
      end
    end
  end

  action_item :custom_action, only: :index do
    link_to 'Recalculate classes', recalculate_go_recess_admin_b2b_tiers_path,
            data: { confirm: 'Are you sure you want to recalculate all disbursement rules and related classes? Note that it can take up to 30 minutes. Before start this job please make sure you have finished editing ranges for all tiers.' }
  end

  collection_action :recalculate, method: :get do
    result = Btb::RecalculateTiers.new.call
    if result == true
      redirect_to({ action: :index }, { notice: 'Started recalculation. It can take up to 30 minutes.' })
    else
      redirect_to({ action: :index }, { alert: "Another recalculation is in progress. Need to recalculate #{result} more classes." })
    end
  end

  #actions defaults: false

  form do |f|
    f.inputs do
      input :name
      input :min_rate, label: 'Minimum Disbursement Rate'
      input :max_rate, label: 'Maximum Disbursement Rate'
      input :override, as: :boolean, label: 'Override with Monthly Cap', input_html: { class: 'override-checkbox' }

      # Conditionally display :monthly_cap input using JavaScript/jQuery
      input :monthly_cap, label: 'Monthly Cap', input_html: { class: 'monthly-cap-input', style: 'display:none;' }
    end

    f.actions

    script do
      raw <<-SCRIPT
        $(document).on('change', '.override-checkbox', function() {
          if ($(this).is(':checked')) {
            $('.monthly-cap-input').show();
          } else {
            $('.monthly-cap-input').hide();
          }
        });
      SCRIPT
    end
  end
end
