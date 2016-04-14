module Stormpath
  module Rails
    module UserConfig
      class Produces
        include Virtus.model

        attribute :accepts, Array, default: ['application/json', 'text/html']
      end
    end
  end
end
