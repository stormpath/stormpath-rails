module Stormpath
  module Rails
    module Config
      class MultitenancyVerification
        attr_reader :web_config

        def initialize(web_config)
          @web_config = web_config
        end

        def call
          verify_multitenancy_set_correctly
        end

        private

        def verify_multitenancy_set_correctly
          return if multitenancy_set_correctly?
          raise(
            InvalidConfiguration,
            'Multitenancy is not set correctly in the configuration file. '\
            "It needs to have a domainName and multitenancy strategy set to 'subdomain'"
          )
        end

        def multitenancy_set_correctly?
          multitenancy.enabled &&
            multitenancy.strategy == 'subdomain' &&
            !web_config.domain_name.nil?
        end

        def multitenancy
          web_config.multi_tenancy
        end
      end
    end
  end
end
