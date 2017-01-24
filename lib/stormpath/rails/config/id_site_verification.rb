module Stormpath
  module Rails
    module Config
      class IdSiteVerification
        attr_reader :web_config

        def initialize(web_config)
          @web_config = web_config
        end

        def call
          verify_id_site_set_correctly
        end

        private

        def verify_id_site_set_correctly
          return if id_site_set_correctly?
          raise(
            InvalidConfiguration,
            "ID site is not set correctly in the configuration file. Make sure the 'callback' is enabled and a uri is specified."
          )
        end

        def id_site_set_correctly?
          id_site.enabled && callback.enabled
        end

        def id_site
          web_config.id_site
        end

        def callback
          web_config.callback
        end
      end
    end
  end
end
