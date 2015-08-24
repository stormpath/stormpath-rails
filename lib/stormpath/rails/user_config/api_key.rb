module Stormpath
  module Rails
    module UserConfig
      class ApiKey
        include Virtus.model

        attribute :file, String
        attribute :id, String
        attribute :secret, String
      end
    end
  end
end