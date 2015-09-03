module Stormpath
  module Rails
    module UserConfig
      class Register 
        include Virtus.model
        
        attribute :enabled, Boolean, default: true
        attribute :uri, String, default: '/register'
        attribute :next_uri, String, default: '/'
      end
    end
  end
end
