module Stormpath
  module Rails
    module Config
      class ApplicationClientApi
        attr_reader :app, :web_config, :client_api_enabled, :client_api_domain

        def initialize(app)
          @app = app
          @web_config = app.web_config
          @client_api_enabled = web_config.status == 'ENABLED'
          @client_api_domain = web_config.domain_name
        end
      end
    end
  end
end
