module Stormpath
  module Rails
    class AuthenticationStatus

      def initialize(response)
        @response = response
      end

      def success?
        @response.instance_of? Stormpath::Authentication::AuthenticationResult
      end

      def error_message
        if @response.instance_of? String
          return @response
        else
          ''
        end
      end
    end
  end
end