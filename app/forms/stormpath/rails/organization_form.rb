module Stormpath
  module Rails
    class OrganizationForm
      attr_reader :name_key

      def initialize(name_key)
        @name_key = name_key
        raise FormError, "Organization Name Key can't be blank" if name_key.blank?
      end

      class FormError < ArgumentError
        def status
          400
        end
      end

      def save!
        begin
          Stormpath::Rails::OrganizationResolver.new(OpenStruct.new(subdomains: [name_key])).organization
        rescue Stormpath::Rails::OrganizationResolver::Error
          raise FormError, 'Organization could not be found'
        end
      end
    end
  end
end
