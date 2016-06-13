module Stormpath
  module Rails
    module Authentication
      private

      def create_stormpath_account(user)
        Client.create_stormpath_account(user)
      end

      def authenticate(user)
        Client.authenticate(user)
      end

      def authenticate_oauth(password_grant_request)
        Client.authenticate_oauth(password_grant_request)
      end

      def reset_password(email)
        Client.reset_password(email)
      end

      def verify_email_token(token)
        Client.verify_email_token(token)
      end

      def create_omniauth_user(provider, access_token)
        Client.create_omniauth_user(provider, access_token)
      end

      def get_account(href)
        Client.get_account(href)
      end

      def find_or_create_user_from_account(account)
        user = find_user_by_email(account.email)
        return user if user

        create_user_from_account(account)
      end

      def create_user_from_account(account)
        user = ::User.new
        user.email = account.email
        user.given_name = account.given_name
        user.surname = account.surname
        user.save

        user
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

      def find_user_by_email(email)
        configuration.user_model.find_user email
      end

      def find_user_by_id(id)
        configuration.user_model.find(id)
      end
    end
  end
end
