module Stormpath
  module Rails
    class UrlBuilder
      attr_reader :request, :host, :path

      def initialize(request, host, path)
        @request = request
        @host = host
        @path = path
      end

      def self.create(request, host, path)
        new(request, host, path).url
      end

      def url
        request_scheme_builder.build(host_and_path).to_s
      end

      private

      def request_scheme_builder
        request.scheme == 'https' ? URI::HTTPS : URI::HTTP
      end

      def host_and_path
        {
          host: host,
          path: path
        }
      end
    end
  end
end
