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

      def account_url
        return '' unless success?
        @response.href.split('/').last
      end
    end
  end
end