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
        if @response.instance_of? Stormpath::Error
          @response.status
        end
      end
    end
  end
end
