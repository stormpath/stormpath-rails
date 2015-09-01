module Stormpath
  module Rails
    module UserConfig
      class Base
        include Virtus.model

        def initialize(options = {})
          yield(self) if block_given?
          super(options)
        end
      end
    end
  end
end
