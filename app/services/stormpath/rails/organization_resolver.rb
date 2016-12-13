module Stormpath
  module Rails
    class OrganizationResolver
      attr_reader :subdomain_name, :organization_name_key

      def initialize(request, organization_name_key = nil)
        @subdomain_name = request.subdomains.try(:first)
        @organization_name_key = organization_name_key
      end

      def organization
        find_organization(subdomain_name) || find_organization(organization_name_key) || raise_error
      end

      class Error < ArgumentError
        def status
          400
        end
      end

      private

      def find_organization(name_key)
        return if name_key.nil?

        application.account_store_mappings.find do |mapping|
          mapping.account_store.try(:name_key) == name_key
        end.try(:account_store)
      end

      def raise_error
        raise Error, "Organization couldn't be resolved"
      end

      def application
        Stormpath::Rails::Client.application
      end
    end
  end
end
