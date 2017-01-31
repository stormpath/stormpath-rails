module Stormpath
  module Rails
    class SocialLoginUrlBuilder
      attr_reader :base_url, :organization_name_key

      def self.call(base_url, options = {})
        new(base_url, options[:organization_name_key])
      end

      def initialize(base_url, organization_name_key = nil)
        @base_url = base_url
        @organization_name_key = organization_name_key
        initialize_directories
      end

      private

      def initialize_directories
        social_directories.each do |account_store|
          instance_variable_set("@#{account_store.provider.provider_id}_login_url",
                                login_url_for(account_store))
        end
      end

      def login_url_for(directory)
        URI.unescape(URI::HTTPS.build(
          host: Stormpath::Rails.config.web.client_api.domain_name,
          path: '/authorize',
          query: query_parameters_for(directory).to_query
        ).to_s)
      end

      def query_parameters_for(directory)
        {}.tap do |body|
          body[:response_type] = 'stormpath_token'
          body[:account_store_href] = directory.href
          body[:scope] = directory.provider.scope.join('+')
          body[:redirect_uri] = "#{base_url}#{Stormpath::Rails.config.web.callback.uri}"
          body[:organization_name_key] = organization_name_key if organization_name_key.present?
        end
      end

      def application
        @application ||= Stormpath::Rails::Client.application
      end

      def social_directories
        @social_directories ||= SocialDirectories.for(application)
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
