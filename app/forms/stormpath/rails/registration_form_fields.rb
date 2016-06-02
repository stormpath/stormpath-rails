module Stormpath
  module Rails
    class RegistrationFormFields
      PREDEFINED_FIELD_NAMES = [
        :given_name,
        :middle_name,
        :surname,
        :username,
        :email,
        :password,
        :confirm_password
      ]

      class << self
        def required_field_names
          required_fields.keys
        end

        def enabled_field_names
          enabled_fields.keys
        end

        def custom_enabled_field_names
          enabled_field_names - PREDEFINED_FIELD_NAMES
        end

        def required_fields
          enabled_fields
            .select  { |_field, properties| properties[:required] }
        end

        def enabled_fields
          register_form_fields
            .select  { |_field, properties| properties[:enabled] }
        end

        def register_form_fields
          Stormpath::Rails.config.web.register.form.fields.to_h
        end
      end
    end
  end
end
