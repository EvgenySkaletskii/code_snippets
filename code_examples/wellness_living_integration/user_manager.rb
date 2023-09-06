module WellnessLiving
  class UserManager
    FIELDS_MAP = {
      1 => :last_name,
      2 => :first_name,
      3 => :email,
      4 => :phone
    }

    def initialize(integration)
      @integration = integration
    end

    def api
      @integration.api
    end

    def get_user_id(user)
      api.login

      user_id = api.search_user(user.email)
      user_id = register_user(user) if user_id.nil?
      user_id
    end

    def register_user(user)
      raw_fields = api.get_client_fields

      fields = raw_fields.map { |f| [FIELDS_MAP[f[:id_field_general]], f[:k_field]] }.to_h

      user_params = {
        fields[:first_name] => user.first_name,
        fields[:last_name] => user.last_name,
        fields[:email] => user.email,
        fields[:phone] => nil
      }

      api.add_client(user_params.sort.to_h)
    end
  end
end
