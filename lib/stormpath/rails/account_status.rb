module Stormpath
  module Rails
    class AccountStatus

      def initialize(response)
        @response = response
      end

      def success?
        @response.instance_of? Stormpath::Resource::Account
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