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

      def setup_accept_header
        request.format =
          ContentTypeNegotiator.new(request.headers['HTTP_ACCEPT']).convert_to_symbol
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
          format.html { redirect_to configuration.web.login.uri }
          format.json { render nothing: true, status: 401 }
        end
      end

      def require_no_authentication!
        redirect_to root_path if signed_in?
      end
    end
  end
end
