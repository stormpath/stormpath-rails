module Stormpath
  module Rails
    class ContentTypeNegotiator
      attr_accessor :accept_header

      HTTP_ACCEPT_WILDCARD = '*/*'
      HTTP_ACCEPT_JSON = 'application/json'
      HTTP_ACCEPT_HTML = 'text/html'

      def initialize(accept_header)
        accept_header = accept_header.presence || HTTP_ACCEPT_WILDCARD
        @accept_header = normalize(accept_header)
      end

      def call
        if accept_header == HTTP_ACCEPT_WILDCARD
          Stormpath::Rails.config.produces.accepts.first
        elsif accept_header.in?(Stormpath::Rails.config.produces.accepts)
          accept_header
        else
          nil
        end
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
