module Stormpath
  module Rails
    module UserConfig
      class Logout
        include Virtus.model

        attribute :enabled, Boolean, default: true
        attribute :uri, String, default: '/logout'
        attribute :next_uri, String, default: '/'

        def reset_attributes
          attributes.keys.each { |attribute_name| reset_attribute(attribute_name) }
        end
      end
    end
  end
end
