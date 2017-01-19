module Stormpath
  module Rails
    class SocialAuthorization
      attr_reader :provider_id, :provider_directory

      def initialize(provider_id)
        @provider_id = provider_id
        initialize_directories
      end

      def login_url
        instance_eval("#{provider_id}_url")
      end

      private

      [:google, :facebook, :github, :linkedin, :twitter].each do |provider|
        define_method("#{provider}_url") do
          URI.unescape(URI::HTTPS.build(
            host: application.web_config.domain_name,
            path: '/authorize',
            query: {
              response_type: 'stormpath_token',
              account_store_href: provider_directory.href,
              scope: provider_directory.provider.scope.join('+'),
              redirect_uri: "http://localhost:3000#{Stormpath::Rails.config.web.callback.uri}"
            }.to_query
          ).to_s)
        end
      end

      def initialize_directories
        application.account_store_mappings.each do |mapping|
          account_store = mapping.account_store
          next unless account_store.class == Stormpath::Resource::Directory
          case account_store.provider.provider_id
          when provider_id.to_s
            @provider_directory = account_store
          end
        end
      end

      def application
        @application ||= Stormpath::Rails::Client.application
      end
    end
  end
end
