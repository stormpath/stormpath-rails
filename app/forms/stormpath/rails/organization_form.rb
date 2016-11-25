module Stormpath
  module Rails
    class OrganizationForm
      attr_accessor :name_key

      def initialize(name_key)
        @name_key = name_key
        validate_organization_name_key_presence
      end

      class FormError < ArgumentError
        def status
          400
        end
      end

      def save!
        raise FormError, 'Organization is not found' unless organization_by_name_key(name_key)
      end

      private

      def validate_organization_name_key_presence
        return if name_key.present?
        raise FormError, "Organization Name Key can't be blank"
      end

      def organization_by_name_key(key)
        Stormpath::Rails::OrganizationResolver.new(
          OpenStruct.new(subdomain: key)
        ).organization
      end
    end
  end
end
