module Stormpath
  module Rails
    module Authentication
      extend ActiveSupport::Concern

      def create_stormpath_account(user)
        Client.create_stormpath_account(user)
      end

      def authenticate(user)
        Client.authenticate(user)
      end

      def reset_password(email)
        Client.reset_password(email)
      end

      def verify_email_token(token)
        Client.verify_email_token(token)
      end

      def update_password(password, account)
        Client.update_password(password, account)
      end

      def id_site_login_url
        Client.id_site_url callback_uri: (request.base_url + configuration.id_site.uri)
      end

      def id_site_register_url
        Client.id_site_url callback_uri: (request.base_url + configuration.id_site.uri), path: '/#register'
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