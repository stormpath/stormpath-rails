module Stormpath
  module Rails
    module Config
      class AccountStoreVerification
        attr_reader :app, :register_is_enabled

        def initialize(app_href, register_is_enabled)
          @app = Stormpath::Rails::Client.client.applications.get(app_href)
          @register_is_enabled = register_is_enabled
        end

        def call
          verify_there_are_any_account_store_mappings
          verify_there_is_a_default_account_store if register_is_enabled
        end

        private

        def verify_there_are_any_account_store_mappings
          return if app_has_account_store_mappings?
          raise(
            InvalidConfiguration,
            'No account stores are mapped to the specified application. Account stores are '\
            'required for login and registration.'
          )
        end

        def verify_there_is_a_default_account_store
          return if app_has_default_account_store_mapping?
          raise(
            InvalidConfiguration,
            'No default account store is mapped to the specified application. A default account '\
            'store is required for registration.'
          )
        end

        def app_has_account_store_mappings?
          app.account_store_mappings.any?
        end

        def app_has_default_account_store_mapping?
          app.default_account_store_mapping.present?
        end
      end
    end
  end
end
