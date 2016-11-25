module Stormpath
  module Rails
    class RegistrationForm
      include ActiveModel::Model
      attr_accessor(*RegistrationFormFields.enabled_field_names)
      attr_accessor :account, :organization_name_key

      validate :validate_presence_of_required_attributes
      validate :validate_password_repeated_twice_matches?

      class FormError < ArgumentError
        def status
          400
        end
      end

      class ArbitraryDataSubmitted < FormError
      end

      def initialize(params = {})
        custom_data_params = params[:customData] || {}
        params = params.except(:customData).merge(custom_data_params)
        params = params.stringify_keys.transform_keys(&:underscore).symbolize_keys

        arbitrary_param_names = params.keys - RegistrationFormFields.enabled_field_names.push(:organization_name_key)

        if arbitrary_param_names.any?
          raise ArbitraryDataSubmitted, "Can't submit arbitrary data: #{arbitrary_param_names.join(', ')}"
        end

        super(params)
      end

      def save
        return false if invalid?

        begin
          self.account = account_resource
        rescue Stormpath::Error => error
          errors.add(:base, error.message) && false
        end
      end

      def save!
        return true if save
        raise(FormError, errors.full_messages.first)
      end

      private

      def account_resource
        if multitenancy_enabled?
          organization.accounts.create(new_account)
        else
          Stormpath::Rails::Client.application.accounts.create(new_account)
        end
      end

      def new_account
        Stormpath::Resource::Account.new(stormpath_registration_params)
      end

      def multitenancy_enabled?
        !organization_name_key.blank?
      end

      def organization
        Stormpath::Rails::Client.client.organizations.search(name_key: organization_name_key).first
      end

      def validate_presence_of_required_attributes
        RegistrationFormFields.required_fields.each do |required_field, properties|
          if send(required_field).blank?
            errors.add(:base, "#{properties[:label]} is required.")
          end
        end
      end

      def validate_password_repeated_twice_matches?
        return unless RegistrationFormFields.confirm_password_enabled?
        return if password == confirm_password
        errors.add(:base, 'Passwords do not match')
      end

      def stormpath_registration_params
        predefined_registration_params.merge(custom_data: custom_registration_params,
                                             organization_name_key: organization_name_key)
      end

      def predefined_registration_params
        {}.tap do |hash|
          RegistrationFormFields.predefined_enabled_field_names.each do |field_name|
            hash[field_name] = send(field_name)
          end
          fill_in_given_name(hash)
          fill_in_surname(hash)
        end
      end

      def custom_registration_params
        {}.tap do |hash|
          RegistrationFormFields.custom_enabled_field_names.each do |field_name|
            hash[field_name] = send(field_name)
          end
        end
      end

      def fill_in_given_name(hash)
        if RegistrationFormFields.given_name_disabled?
          hash[:given_name] = 'UNKNOWN'
        elsif RegistrationFormFields.given_name_not_required? && given_name.blank?
          hash[:given_name] = 'UNKNOWN'
        end
      end

      def fill_in_surname(hash)
        if RegistrationFormFields.surname_disabled?
          hash[:surname] = 'UNKNOWN'
        elsif RegistrationFormFields.surname_not_required? && surname.blank?
          hash[:surname] = 'UNKNOWN'
        end
      end
    end
  end
end
