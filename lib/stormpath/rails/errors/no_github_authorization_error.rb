module Stormpath
  module Rails
    class NoGithubAuthorizationError < ArgumentError
      def message
        'An error occured while authenticating your account on GitHub'
      end
    end
  end
end
