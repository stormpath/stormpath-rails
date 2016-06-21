module Stormpath
  module Rails
    class BaseController < ApplicationController
      before_action :setup_accept_header
      skip_before_action :verify_authenticity_token, if: :api_request?
      skip_before_action :verify_authenticity_token, if: :in_development?

      helper_method :current_account, :signed_in?

      layout 'stormpath'

      private

      def api_request?
        request.format == :json
      end

      # Enable to test with the TCK.
      def in_development?
        ::Rails.env.development?
      end

      def set_flash_message(key, message)
        flash[key] = message if message.present?
      end

      def setup_accept_header
        request.format =
          ContentTypeNegotiator.new(request.headers['HTTP_ACCEPT']).convert_to_symbol
      end

      def current_account
        @current_account ||= begin
          ControllerAuthenticator.new(self).authenticate!
        rescue ControllerAuthenticator::UnauthenticatedRequest
          nil
        end
      end

      def signed_in?
        !!current_account
      end

      # def signed_in?
      #   false
      # end
      #
      # def current_account
      #   @current_account ||=
      #     AccountFromAccessToken.new(cookies[configuration.web.access_token_cookie.name]).account
      # end

      def authenticate_account!
        return if current_account.present?
        respond_to do |format|
          format.html { redirect_to configuration.web.login.uri }
          format.json { render nothing: true, status: 401 }
        end
      end

      # def current_account
      #   @current_account ||= begin
      #     if stormpath_access_token_cookie || stormpath_refresh_token_cookie
      #       AccountFromAccessToken.new(cookies[configuration.web.access_token_cookie.name]).account
      #     elsif request.env["Authorization"] =~ /^Bearer /
      #
      #     elsif request.env["Authorization"] =~ /^Basic /
      #
      #     end
      #   end
      # end

      def require_no_authentication
        redirect_to root_path if signed_in?
      end
    end
  end
end
