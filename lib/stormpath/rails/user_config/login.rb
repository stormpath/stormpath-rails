module Stormpath
  module Rails
    module UserConfig
      class Login
        include Virtus.model

        attribute :enabled, Boolean, default: true
        attribute :uri, String, default: '/login'
        attribute :next_uri, String, default: '/'

        def reset_attributes
          attributes.keys.each { |attribute_name| reset_attribute(attribute_name) }
        end
      end
    end
  end
end
