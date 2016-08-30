module Stormpath
  module Rails
    module Config
      class SocialLoginVerification
        attr_reader :app, :register_is_enabled, :facebook, :github, :google, :linkedin

        def initialize(app_href, register_is_enabled)
          @app = Stormpath::Rails::Client.client.applications.get(app_href)
          @register_is_enabled = register_is_enabled
          initialize_directories if register_is_enabled
        end

        private

        def initialize_directories
          app.account_store_mappings.each do |mapping|
            account_store = mapping.account_store
            case account_store.try(:provider).try(:provider_id)
            when 'facebook'
              @facebook = account_store
            when 'github'
              @github = account_store
            when 'google'
              @google = account_store
            when 'linkedin'
              @linkedin = account_store
            end
          end
        end
      end
    end
  end
end
