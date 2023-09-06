module WellnessLiving
  class Api
    include WellnessLivingHelper

    attr_reader :business_id,
                :user_email,
                :user_password,
                :user_id,
                :api_client

    def initialize(configs)
      @business_id   = configs.fetch(:business_id)
      @user_email    = configs.fetch(:user_email)
      @user_password = configs.fetch(:user_password)
      @user_id       = configs.fetch(:user_id)
      @api_client = WellnessLiving::ApiClient.new(configs)
    end

    def locations
      query = { k_business: business_id }

      response = api_client.execute(meth: :get, resource: 'Wl/Location/List.json', query: query)
      response[:a_location].values
    end

    def staff
      query = { k_business: business_id }

      response = api_client.execute(meth: :get, resource: 'Wl/Staff/StaffList/StaffList.json', query: query)
      response[:a_staff].values
    end

    def class_tabs(location)
      query = {
        k_business: business_id,
        k_location: location,
        uid: user_id
      }

      response = api_client.execute(meth: :get, resource: 'Wl/Schedule/Tab/Tab.json', query: query)
      response[:a_tab]
    end

    def class_list(options)
      query = {
        dt_date: options[:start_date],
        dt_end: options[:end_date],
        is_tab_all: 1,
        k_business: business_id,
        show_cancel: 0
      }

      response = api_client.execute(meth: :get, resource: 'Wl/Schedule/ClassList/ClassList.json', query: query)
      response[:a_session]
    end

    def scheduled_class_info(external_id)
      query = {
        dt_date: Time.now.strftime('%Y-%m-%d %H:%M:%S'), # they accept any date in the specified format
        k_business: business_id,
        k_class_period: external_id
      }

      response = api_client.execute(meth: :get, resource: 'Wl/Schedule/ClassView/ClassView.json', query: query)
      response[:a_class]
    end

    def classes(schedule)
      query = {
        k_business: business_id
      }

      body = {
        s_session_request: schedule.to_json
      }

      response = api_client.execute(meth: :post, resource: 'Wl/Schedule/ClassView/ClassView.json', query: query, body: body)
      response[:a_session_result]
    end

    def book_class(options)
      query = {
        dt_date_gmt: options[:date],
        id_mode: 4,
        k_class_period: options[:class_period],
        uid: options[:user_id]
      }

      body = {
        is_agree: 0
      }

      api_client.execute(meth: :post, resource: 'Wl/Book/Process/Info/Info54.json', query: query, body: body)
    end

    def cancel_class(options)
      query = { 
        dt_date: options[:date],
        is_backend: 1,
        k_class_period: options[:class_period],
        uid: options[:user_id]
      }

      api_client.execute(meth: :post, resource: 'Wl/Schedule/Cancel.json', query: query)
    end

    def business_name
      query = {
        k_business: business_id
      }

      response = api_client.execute(meth: :get, resource: 'Wl/Business/Data.json', query: query)
      response[:text_title]
    end

    def search_user(email)
      query = {
        k_business: business_id,
        text_search: email
      }

      response = api_client.execute(meth: :get, resource: 'Wl/Login/Search/StaffApp/List.json', query: query)
      response[:a_list].dig(0, :uid)
    end

    def get_client_fields(business = business_id)
      query = {
        k_business: business,
        k_skin: nil
      }

      response = api_client.execute(meth: :get, resource: 'Wl/Lead/Lead.json', query: query)
      response[:a_field_list]
    end

    def add_client(params)
      query = {
        k_business: business_id
      }

      body = {
        a_field_data: params
      }

      response = api_client.execute(meth: :post, resource: 'Wl/Lead/Lead.json', query: query, body: body)
      response[:uid]
    end

    def login
      enter(notepad)
    end

    private

    def notepad
      query = { s_login: user_email }

      response = api_client.execute(meth: :get, resource: 'Core/Passport/Login/Enter/Notepad.json', query: query)
      response[:s_notepad]
    end

    def enter(notepad)
      body = {
        s_login: user_email,
        s_password: api_client.password_compute(user_password, notepad),
        s_notepad: notepad,
        s_remember: '' # don't remember user's state
      }

      api_client.execute(meth: :post, resource: 'Core/Passport/Login/Enter/Enter.json', body: body)
    end
  end
end
