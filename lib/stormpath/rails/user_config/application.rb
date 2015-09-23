module Stormpath
  module Rails
    module UserConfig
      class Application
        include Virtus.model

        attribute :name, String
        attribute :href, String
      end
    end
  end
end
