module Stormpath
  module Rails
    class BaseUrlInitializer
      DEFAULT_API_VERSION = 1
      DEFAULT_API_SCHEME = 'https'.freeze
      attr_reader :application_uri, :base_url

      def initialize(application_href)
        @application_uri = URI(application_href)
        @base_url = extract_base_url_from_uri
      end

      def self.call(application_href)
        if application_href.blank?
          raise(InvalidConfiguration,
                'Please set the application href in your configuration options.')
        end
        new(application_href).base_url
      end

      private

      def extract_base_url_from_uri
        "#{DEFAULT_API_SCHEME}://#{host}/v#{DEFAULT_API_VERSION}"
      end

      def host
        application_uri.host
      end
    end
  end
end
