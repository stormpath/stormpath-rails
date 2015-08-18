module Stormpath
  module Rails
    module Authentication
      extend ActiveSupport::Concern

      included do
        helper_method :current_user, :signed_in?, :signed_out?
        hide_action(
          :current_user,
          :signed_in?,
          :signed_out?,
          :create_stormpath_account,
          :authenticate,
          :logout,
          :find_user_by_email,
          :find_user_by_id,
          :signed_out?,
          :initialize_session,
          :reset_session
        )
      end

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

      def id_site_url(options)
        Client.id_site_url(options)
      end

      def logout
        reset_session
      end

      def find_user_by_email(email)
        Stormpath::Rails.config.user_model.find_user email
      end

      def find_user_by_id(id)
        Stormpath::Rails.config.user_model.find(id)
      end

      def signed_in?
        !session[:user_id].nil?
      end

      def signed_out?
        !signed_in?
      end

      def current_user
        @current_user ||= Stormpath::Rails.config.user_model.find(session[:user_id]) if session[:user_id]
      end

      def initialize_session(user)
        session[:user_id] = user.id
      end

      def reset_session
        session[:user_id] = nil
      end
    end
  end
end