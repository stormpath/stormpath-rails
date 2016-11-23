module Stormpath
  module Rails
    class OrganizationResolver
      attr_accessor :subdomain

      def initialize(request)
        @subdomain = request.subdomain
      end

      def organization
        application.account_store_mappings.find do |mapping|
          mapping.account_store.try(:name_key) == subdomain
        end.try(:account_store)
      end

      private

      def application
        Stormpath::Rails::Client.application
      end
    end
  end
end
