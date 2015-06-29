module Stormpath
  module Rails
    module Authentication
      extend ActiveSupport::Concern

      included do
        helper_method :signed_in?
        hide_action :signed_in?
      end

      def create_stormpath_account(user)
        Stormpath::Rails::Client.create_stormpath_account(user)
      end

      def authenticate(user)
        Stormpath::Rails::Client.authenticate(user)
      end

      def find_user(email)
        Stormpath::Rails.config.user_model.find_user email
      end

      def signed_in?
        !session[:user].nil?
      end
    end
  end
end