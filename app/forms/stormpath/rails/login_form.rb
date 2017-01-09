module Stormpath
  module Rails
    class LoginForm
      attr_accessor :login, :password, :authentication_result, :organization_name_key
      delegate :account, to: :authentication_result

      def initialize(login, password, options = {})
        @login = login
        @password = password
        @organization_name_key = options[:organization_name_key]
        validate_login_presence
        validate_password_presence
      end

      class FormError < ArgumentError
        def status
          400
        end
      end

      def save!
        self.authentication_result = application.authenticate_oauth(password_grant_request)
      end

      private

      def validate_login_presence
        return if login.present?
        raise FormError, "#{form_fields_config.login.label} can't be blank"
      end

      def validate_password_presence
        return if password.present?
        raise FormError, "#{form_fields_config.password.label} can't be blank"
      end

      def form_fields_config
        Stormpath::Rails.config.web.login.form.fields
      end

      def password_grant_request
        Stormpath::Oauth::PasswordGrantRequest.new(login,
                                                   password,
                                                   organization_name_key: organization_name_key)
      end

      def application
        Stormpath::Rails::Client.application
      end
    end
  end
end
