module Stormpath
  module Rails
    module Social
      extend ActiveSupport::Concern

      included do
        helper_method :facebook_login_enabled?, :facebook_app_id
        hide_action(
          :facebook_login_enabled?,
          :facebook_app_id
        )
      end

      def facebook_login_enabled?
        configuration.facebook.enabled? 
      end

      def facebook_app_id
        configuration.facebook.app_id
      end
    end
  end
end
