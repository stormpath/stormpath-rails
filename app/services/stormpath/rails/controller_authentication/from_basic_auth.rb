module Stormpath
  module Rails
    class ControllerAuthentication
      class FromBasicAuth
        attr_reader :authorization_header

        def initialize(authorization_header)
          @authorization_header = authorization_header
        end

        def authenticate!
          raise UnauthenticatedRequest if fetched_api_key.nil?
          raise UnauthenticatedRequest if fetched_api_key.secret != api_key_secret
          fetched_api_key.account
        end

        private

        def fetched_api_key
          @fetched_api_key ||= Client.application.api_keys.search(id: api_key_id).first
        end

        def api_key_id
          decoded_authorization_header.first
        end

        def api_key_secret
          decoded_authorization_header.last
        end

        def decoded_authorization_header
          @decoded_authorization_header ||= begin
            api_key_and_secret = Base64.decode64(basic_authorization_header).split(':')
            raise UnauthenticatedRequest if api_key_and_secret.count != 2
            api_key_and_secret
          end
        end

        def basic_authorization_header
          authorization_header.gsub(BASIC_PATTERN, '')
        end
      end
    end
  end
end
