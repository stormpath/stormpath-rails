module Stormpath
  module Rails
    class AuthenticationStatus
      def initialize(response)
        @response = response
      end

      def success?
        @response.instance_of? Stormpath::Authentication::AuthenticationResult
      end

      def account
        @response.account
      end

      def error_message
        if @response.instance_of? Stormpath::Error
          @response.message
        else
          ''
        end
      end

      def status
        @response.status if @response.instance_of? Stormpath::Error
      end
    end
  end
end
