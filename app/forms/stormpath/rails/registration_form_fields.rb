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

        def predefined_enabled_field_names
          enabled_field_names & PREDEFINED_FIELD_NAMES
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

        def confirm_password_enabled?
          form_fields_config.confirm_password.enabled
        end

        def register_form_fields
          form_fields_config.to_h
        end

        def given_name_disabled?
          !form_fields_config.given_name.enabled
        end

        def given_name_not_required?
          !form_fields_config.given_name.required
        end

        def surname_disabled?
          !form_fields_config.surname.enabled
        end

        def surname_not_required?
          !form_fields_config.surname.required
        end

        def form_fields_config
          Stormpath::Rails.config.web.register.form.fields
        end
      end
    end
  end
end
