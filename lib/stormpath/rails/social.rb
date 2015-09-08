module Stormpath
  module Rails
    module Social
      extend ActiveSupport::Concern

      included do
        helper_method :facebook_login_enabled?, :facebook_app_id,
          :google_login_enabled?, :google_client_id, :social_auth?
        hide_action(
          :facebook_login_enabled?,
          :google_login_enabled?,
          :facebook_app_id,
          :google_client_id
        )
      end

      def facebook_login_enabled?
        configuration.facebook.enabled? 
      end

      def google_login_enabled?
        configuration.google.enabled?
      end

      def facebook_app_id
        configuration.facebook.app_id
      end

      def google_client_id
        configuration.google.client_id
      end

      def social_auth?
        facebook_login_enabled? || google_login_enabled?
      end
    end
  end
end
