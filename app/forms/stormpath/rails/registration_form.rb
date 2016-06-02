module Stormpath
  module Rails
    class RegistrationForm
      include ActiveModel::Model
      attr_accessor *RegistrationFormFields.enabled_field_names

      # validate :validate_no_unknown_fields_submitted

      validate :validate_presence_of_required_attributes

      def initialize(params = {})
        custom_data_params = params.delete(:customData) || {}
        params.merge!(custom_data_params)
        super(params.stringify_keys.transform_keys(&:underscore))
      end

      def save
        return false if invalid?

      end

      private

      def validate_presence_of_required_attributes
        RegistrationFormFields.required_fields.each do |required_field, properties|
          if self.send(required_field).blank?
            errors.add(:base, "#{properties[:label]} can't be blank")
          end
        end
      end
    end
  end
end
