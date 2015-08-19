module Stormpath
  module Rails
    module Session
      extend ActiveSupport::Concern

      included do
        helper_method :current_user, :signed_in?, :signed_out?
        hide_action(
          :current_user,
          :signed_in?,
          :signed_out?,
          :logout,
          :initialize_session,
          :reset_session
        )
      end

      def initialize_session(user)
        session[:user_id] = user.id
      end

      def reset_session
        session[:user_id] = nil
      end

      def logout
        reset_session
      end

      def signed_in?
        !session[:user_id].nil?
      end

      def signed_out?
        !signed_in?
      end

      def current_user
        @current_user ||= configuration.user_model.find(session[:user_id]) if session[:user_id]
      end
    end
  end
end