module Stormpath
  module Rails
    module UserConfig
      class Facebook
        include Virtus.model

        attribute :app_id, String
        attribute :app_secret, String

        def enabled?
          !(self.app_id.blank? && self.app_secret.blank?)
        end
      end
    end
  end
end
