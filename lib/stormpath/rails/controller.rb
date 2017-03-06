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

      private

      def current_account
        @current_account ||= begin
          cookies =
            if respond_to?(:cookies)
              cookies
            else
              {}
            end

          ControllerAuthentication.new(cookies, request.headers['Authorization']).authenticate!
        rescue ControllerAuthentication::UnauthenticatedRequest, Stormpath::Error, JWT::DecodeError
          nil
        end
      end

      def signed_in?
        current_account.present?
      end

      def require_authentication!
        return if signed_in?
        respond_to do |format|
          format.html { redirect_to "#{stormpath_config.web.login.uri}?next=#{request.path}" }
          format.json do
            response.headers['WWW-Authenticate'] = "Bearer realm=\"My Application\""
            render nothing: true, status: 401
          end
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
