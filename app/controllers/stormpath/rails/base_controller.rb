module Stormpath
  module Rails
    class BaseController < ApplicationController
      before_action :setup_accept_header
      skip_before_action :verify_authenticity_token, if: :api_request?
      skip_before_action :verify_authenticity_token, if: :in_development?

      layout 'stormpath'

      private

      def api_request?
        request.content_type == "application/json"
      end

      # Enable to test with the TCK.
      def in_development?
        ::Rails.env.development?
      end

      def set_flash_message(key, message)
        flash[key] = message if message.present?
      end

      def setup_accept_header
        request.headers['HTTP_ACCEPT'] =
          ContentTypeNegotiator.new(request.headers['HTTP_ACCEPT']).convert
      end
    end
  end
end
