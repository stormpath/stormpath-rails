module Stormpath
  module Rails
    module Controller
      extend ActiveSupport::Concern
      include Stormpath::Rails::Social

      included do
        if respond_to?(:helper_method)
          helper_method :current_account, :signed_in?
        end
      end

      def current_account
        @current_account ||= begin
          ControllerAuthentication.new(cookies, request.headers['Authorization']).authenticate!
        rescue ControllerAuthentication::UnauthenticatedRequest
          nil
        end
      end

      def signed_in?
        current_account.present?
      end

      def require_authentication!
        return if signed_in?
        respond_to do |format|
          format.html { redirect_to stormpath_config.web.login.uri }
          format.json { render nothing: true, status: 401 }
        end
      end

      def require_no_authentication!
        redirect_to root_path if signed_in?
      end

      def stormpath_config
        Stormpath::Rails.config
      end
    end
  end
end
