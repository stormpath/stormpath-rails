module Stormpath
  module Rails
    module Session
      # extend ActiveSupport::Concern
      #
      # included do
      #   helper_method :current_user, :signed_in?, :signed_out?
      # end
      #
      # private
      #
      # def initialize_session(user, href)
      #   session[:user_id] = user.id
      #   session[:user_href] = href
      # end
      #
      # def reset_session
      #   session[:user_id] = nil
      #   session[:user_href] = nil
      # end
      #
      # def logout
      #   reset_session
      # end
      #
      # def signed_in?
      #   !session[:user_id].nil?
      # end
      #
      # def signed_out?
      #   !signed_in?
      # end
      #
      # def current_user
      #   # @current_user ||= configuration.user_model.find(session[:user_id]) if session[:user_id]
      # end
      #
      # def current_user_href
      #   session[:user_href] if session[:user_href]
      # end
    end
  end
end
