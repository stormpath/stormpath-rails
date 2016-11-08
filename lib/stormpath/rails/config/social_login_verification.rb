module Stormpath
  module Rails
    module Config
      class SocialLoginVerification
        attr_reader :app,
                    :facebook_app_id,
                    :facebook_app_secret,
                    :github_app_id,
                    :github_app_secret,
                    :google_app_id,
                    :linkedin_app_id

        def initialize(app_href)
          @app = Stormpath::Rails::Client.client.applications.get(app_href)
          initialize_directories
        end

        private

        def initialize_directories
          app.account_store_mappings.each do |mapping|
            account_store = mapping.account_store
            next unless account_store.class == Stormpath::Resource::Directory
            case account_store.provider.provider_id
            when 'facebook'
              @facebook_app_id = account_store.provider.client_id
              @facebook_app_secret = account_store.provider.client_secret
            when 'github'
              @github_app_id = account_store.provider.client_id
              @github_app_secret = account_store.provider.client_secret
            when 'google'
              @google_app_id = account_store.provider.client_id
            when 'linkedin'
              @linkedin_app_id = account_store.provider.client_id
            end
          end
        end
      end
    end
  end
end
