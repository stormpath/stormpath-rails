module Stormpath
  module Rails
    class Client
      class << self
        attr_accessor :connection
      end

      def self.handle_id_site_callback(url)
        response = application.handle_id_site_callback(url)
        client.accounts.get response.account_href
      end

      def self.id_site_url(options)
        application.create_id_site_url callback_uri: options[:callback_uri], path: options[:path]
      end

      def self.create_omniauth_user(provider, access_token)
        request = Stormpath::Provider::AccountRequest.new(provider, :access_token, access_token)
        application.get_provider_account(request)
      end

      def self.application
        client.applications.get Stormpath::Rails.config.application.href
      end

      def self.client
        self.connection ||= Stormpath::Client.new(api_key: locate_api_key)
      end

      def self.locate_api_key
        EnvNamesWarning.check_env_variable_names
        {
          id: ENV['STORMPATH_CLIENT_APIKEY_ID'] || ENV['STORMPATH_API_KEY_ID'],
          secret: ENV['STORMPATH_CLIENT_APIKEY_SECRET'] || ENV['STORMPATH_API_KEY_SECRET']
        }
      end
    end
  end
end
