module Stormpath
  module Rails
    module Social
      extend ActiveSupport::Concern

      included do
        helper_method :facebook_login_enabled?
      end

      def facebook_login_enabled?
        configuration.facebook.enabled? 
      end
    end
  end
end
