module Stormpath
  module Rails
    class SocialAuthorization
      attr_reader :base_url

      def self.build_login_urls(request)
        new(request.base_url)
      end

      def initialize(base_url)
        @base_url = base_url
        initialize_directories
      end

      private

      def initialize_directories
        application.account_store_mappings.each do |mapping|
          account_store = mapping.account_store
          next unless social_directory?(account_store)
          instance_variable_set("@#{account_store.provider.provider_id}_login_url",
                                generate_url(account_store))
        end
      end

      def generate_url(directory)
        URI.unescape(URI::HTTPS.build(
          host: Stormpath::Rails.config.web.client_api.domain_name,
          path: '/authorize',
          query: {
            response_type: 'stormpath_token',
            account_store_href: directory.href,
            scope: directory.provider.scope.join('+'),
            redirect_uri: "#{base_url}#{Stormpath::Rails.config.web.callback.uri}"
          }.to_query
        ).to_s)
      end

      def social_directory?(account_store)
        account_store.class == Stormpath::Resource::Directory &&
          account_store.provider.respond_to?(:client_id)
      end

      def application
        @application ||= Stormpath::Rails::Client.application
      end

      def method_missing(method_name, *args, &block)
        if instance_variable_names.include? "@#{method_name}"
          instance_variable_get "@#{method_name}"
        else
          ''
        end
      end

      def respond_to_missing?(method_name, include_private = false)
        method_name.to_s.end_with?('_login_url') || super
      end
    end
  end
end
