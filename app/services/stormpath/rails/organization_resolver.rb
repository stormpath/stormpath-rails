module Stormpath
  module Rails
    class OrganizationResolver
      attr_accessor :subdomain, :organization_name_key

      def initialize(request, organization_name_key = nil)
        @subdomain = request.subdomain
        @organization_name_key = organization_name_key
      end

      def organization
        from_host || from_body
      end

      private

      def application
        Stormpath::Rails::Client.application
      end

      def from_host
        application.account_store_mappings.find do |mapping|
          mapping.account_store.try(:name_key) == subdomain
        end.try(:account_store)
      end

      def from_body
        unless organization_name_key.nil?
          self.class.new(OpenStruct.new(subdomain: organization_name_key)).organization
        end
      end
    end
  end
end
