module Stormpath
  module Rails
    class LoginForm
      include ActiveModel::Model
      attr_accessor :login, :password
      attr_accessor :authentication_result

      validate :validate_login_presence
      validate :validate_password_presence

      class FormError < ArgumentError
        def status
          400
        end
      end

      def save
        return false if invalid?
        result = Client.authenticate_oauth(password_grant_request)

        if result.success?
          self.authentication_result = result.authentication_result
        else
          errors.add(:base, result.error_message) && false
        end
      end

      def save!
        raise(FormError, errors.full_messages.first) if invalid?
        self.authentication_result = Client.application.authenticate_oauth(password_grant_request)
      end

      private

      def validate_login_presence
        errors.add(:base, "#{form_fields_config.login.label} can't be blank") if login.blank?
      end

      def validate_password_presence
        errors.add(:base, "#{form_fields_config.password.label} can't be blank") if password.blank?
      end

      def form_fields_config
        Stormpath::Rails.config.web.login.form.fields
      end

      def password_grant_request
        Stormpath::Oauth::PasswordGrantRequest.new(login, password)
      end
    end
  end
end
