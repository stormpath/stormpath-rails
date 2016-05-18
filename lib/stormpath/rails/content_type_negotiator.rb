module Stormpath
  module Rails
    class ContentTypeNegotiator
      attr_accessor :accept_header

      HTTP_ACCEPT_WILDCARD = '*/*'
      HTTP_ACCEPT_JSON = 'application/json'
      HTTP_ACCEPT_HTML = 'text/html'

      FULL_NAME_TO_SYMBOL = {
        HTTP_ACCEPT_JSON => :json,
        HTTP_ACCEPT_HTML => :html
      }

      def initialize(accept_header)
        accept_header = accept_header.presence || HTTP_ACCEPT_WILDCARD
        @accept_header = normalize(accept_header)
      end

      def convert
        if accept_header == HTTP_ACCEPT_WILDCARD
          Stormpath::Rails.config.web.produces.first
        elsif accept_header.in?(Stormpath::Rails.config.web.produces)
          accept_header
        end
      end

      def convert_to_symbol
        FULL_NAME_TO_SYMBOL[convert]
      end

      def handle_by_stormpath?
        accept_header.in?([HTTP_ACCEPT_WILDCARD] + Stormpath::Rails.config.web.produces)
      end

      private

      def normalize(accept_header)
        return accept_header unless accept_header.include?(',')

        if accept_header.include?(HTTP_ACCEPT_JSON)
          HTTP_ACCEPT_JSON
        elsif accept_header.include?(HTTP_ACCEPT_HTML)
          HTTP_ACCEPT_HTML
        else
          nil
        end
      end
    end
  end
end
