module Stormpath
  module Rails
    module Authentication
      private

      def create_stormpath_account(user)
        Client.create_stormpath_account(user)
      end

      def authenticate_oauth(password_grant_request)
        Client.authenticate_oauth(password_grant_request)
      end

      def reset_password(email)
        Client.reset_password(email)
      end

      def create_omniauth_user(provider, access_token)
        Client.create_omniauth_user(provider, access_token)
      end

      def id_site_login_url
        Client.id_site_url callback_uri: (request.base_url + configuration.web.id_site.uri)
      end

      def id_site_register_url
        Client.id_site_url callback_uri: (request.base_url + configuration.web.id_site.uri), path: '/#register'
      end

      def handle_id_site_callback(url)
        Client.handle_id_site_callback(url)
      end

      def configuration
        Stormpath::Rails.config
      end
    end
  end
end
