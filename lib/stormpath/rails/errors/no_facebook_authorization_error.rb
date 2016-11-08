module Stormpath
  module Rails
    class NoFacebookAuthorizationError < ArgumentError
      def message
        'An error occured while authenticating your account on Facebook'
      end
    end
  end
end
