module Stormpath
  module Rails
    module UserConfig
      class Google 
        include Virtus.model

        attribute :client_id, String
        attribute :client_secret, String

        def enabled?
          !(self.client_id.blank? && self.client_secret.blank?)
        end
      end
    end
  end
end
