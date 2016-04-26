module Stormpath
  module Rails
    module UserConfig
      class AccessTokenCookie
        include Virtus.model

        attribute :name,      String,  default: 'access_token'
        attribute :http_only, Boolean, default: true
        attribute :secure,    Boolean
        attribute :path,      String
        attribute :domain,    String
      end
    end
  end
end
