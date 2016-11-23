module Stormpath
  module Rails
    class OrganizationResolver
      attr_accessor :subdomain

      def initialize(request)
        @subdomain = request.subdomain
      end

      def organization
        Stormpath::Rails::Client.client.organizations.search(name_key: subdomain).try(:first)
      end
    end
  end
end
