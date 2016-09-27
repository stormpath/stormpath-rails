module Stormpath
  module Rails
    class PayloadBuilder
      attr_reader :resource, :cb_uri

      def initialize(resource, options = {})
        @resource = resource
        @cb_uri = options[:cb_uri]
      end

      def jwt
        JWT.encode(payload, ENV['STORMPATH_API_KEY_SECRET'], 'HS256')
      end

      private

      def payload
        {
          'iat' => Time.now.to_i,
          'iss' => ENV['STORMPATH_API_KEY_ID'],
          'sub' => ENV['STORMPATH_APPLICATION_URL'],
          'cb_uri' => cb_uri,
          'jti' => SecureRandom.uuid,
          'path' => path,
          'state' => ''
        }
      end

      def path
        if resource == :register
          Stormpath::Rails.config.web.id_site.register_uri
        else
          Stormpath::Rails.config.web.id_site.login_uri
        end
      end
    end
  end
end
