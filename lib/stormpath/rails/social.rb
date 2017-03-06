module Stormpath
  module Rails
    module Social
      extend ActiveSupport::Concern

      included do
        if respond_to?(:helper_method)
          helper_method :social_providers_present?
        end
      end

      private

      def social_providers_present?
        Stormpath::Rails.config.web.has_social_providers
      end
    end
  end
end
