module Stormpath
  module Rails
    class BaseController < ApplicationController
      include Stormpath::Rails::Controller

      before_action :setup_accept_header
      skip_before_action :verify_authenticity_token, if: :api_request?
      skip_before_action :verify_authenticity_token, if: :in_development?

      layout 'stormpath/rails/layouts/stormpath'

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

      def organization_resolution?
        params.key?(:organization_name_key) && !params.key?(:password)
      end

      def organization_unresolved?
        stormpath_config.web.multi_tenancy.enabled &&
          req.host != stormpath_config.web.domain_name &&
          current_organization_name_key.nil?
      end

      def current_organization
        if stormpath_config.web.multi_tenancy.enabled
          Stormpath::Rails::OrganizationResolver.new(req, params[:organization_name_key])
                                                .organization
        end
      end

      def current_organization_name_key
        begin
          current_organization.try(:name_key)
        rescue Stormpath::Rails::OrganizationResolver::Error
          nil
        end
      end
      helper_method :current_organization_name_key

      def req
        request
      end
    end
  end
end
