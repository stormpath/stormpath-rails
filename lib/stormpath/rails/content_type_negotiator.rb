module Stormpath
  module Rails
    class ContentTypeNegotiator
      attr_accessor :accept_header

      def initialize(accept_header)
        accept_header = accept_header.presence || '*/*'
        @accept_header = normalize(accept_header)
      end

      def call
        if accept_header == "*/*"
          Stormpath::Rails.config.produces.accepts.first
        elsif accept_header.in?(Stormpath::Rails.config.produces.accepts)
          accept_header
        end
      end

      def normalize(accept_header)
        return accept_header unless accept_header.include?(',')

        if accept_header.include?('application/json')
          'application/json'
        elsif accept_header.include?('html/text')
          'html/text'
        end
      end
    end
  end
end
