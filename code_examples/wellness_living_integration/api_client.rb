require 'rest_client'
require 'sha3'

module WellnessLiving
  class ApiClient
    include WellnessLivingHelper

    HOST = FitReserve.config[:wellness_living][:host]
    BASE_URL = "https://#{HOST}/"
    USER_AGENT = 'FitReserve API 1.0'

    attr_reader :auth_code,
                :auth_id,
                :headers,
                :cookies

    def initialize(configs = {})
      @auth_code     = configs.fetch(:auth_code)
      @auth_id       = configs.fetch(:auth_id)
      @headers       = {
        'User-Agent' => USER_AGENT,
        'Host' => HOST
      }
      @cookies = {
        p: nil,
        t: nil
      }
    end

    def signature_compute(params)
      variables = []

      params[:variables].sort.to_h.each do |key, value|
        if value.is_a?(Hash)
          value.each do |inner_key, inner_value|
            variables << "#{key}[#{inner_key}]=#{inner_value}"
          end
        else
          variables << "#{key}=#{value}"
        end
      end

      signature = [
        'Core\\Request\\Api::20150518',
        params[:date],
        auth_code,
        HOST,
        auth_id,
        params[:meth],
        params[:resource],
        cookies[:p],
        cookies[:t],
        *variables,

        "user-agent:#{USER_AGENT}"
      ]

      Digest::SHA2.new(256).hexdigest signature.join("\n")
    end

    def password_compute(password, notepad)
      delimeters = [
        'r',
        '4S',
        'zqX',
        'zqiOK',
        'TLVS75V',
        'Ue5aLaIIG75',
        'uODJYM2JsCX4G',
        'kt58wZfHHGQkHW4QN',
        'Lh9Fl5989crMU4E7P6E'
      ]

      password_hash = SHA3::Digest.hexdigest(:sha512, delimeters.join(password) + password)

      SHA3::Digest.hexdigest(:sha512, notepad + password_hash)
    end

    def set_signature(signature)
      headers['Authorization'] = "20150518,#{auth_id},User-Agent,#{signature}"
    end

    def set_date
      time = Time.now.in_time_zone('UTC')

      headers['Date'] = gtm_date(time)

      iso_date(time)
    end

    def set_cookies(params)
      cookies[:p] = params['p']
      cookies[:t] = params['t']
    end

    def execute(meth:, resource:, query: {}, body: nil)
      signature = signature_compute(
        date: set_date,
        meth: meth.to_s.upcase,
        resource: resource,
        variables: query.merge(body.to_h)
      )

      set_signature(signature)

      if query.empty?
        request_headers = headers
      else
        request_headers = headers.merge({params: query})
      end

      raw = RestClient::Request.execute(
        method: meth,
        url: "#{BASE_URL}#{resource}",
        headers: request_headers,
        cookies: cookies,
        payload: body
      )

      set_cookies(raw.cookies)

      response = JSON.parse raw, symbolize_names: true

      unless response[:a_error].nil?
        raise WellnessLiving::Exceptions::ApiFailed.new("WellnessLiving API error: #{response.dig(:a_error, 0, :s_message)}")
      end

      response
    end
  end
end
