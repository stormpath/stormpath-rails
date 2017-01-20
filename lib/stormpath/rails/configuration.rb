module Stormpath
  module Rails
    InvalidConfiguration = Class.new(ArgumentError)
    DEFAULT_CONFIG_RELATIVE_FILE_PATH =
      '../../../../lib/generators/stormpath/install/templates/default_config.yml'.freeze

    class Configuration
      attr_reader :user_defined_config_hash

      def initialize(user_defined_config_hash)
        @user_defined_config_hash = user_defined_config_hash
      end

      def application
        config_object.stormpath.application
      end

      def web
        config_object.stormpath.web
      end

      def config_object
        @config_object ||= RecursiveOpenStruct.new(merged_config_hashes).tap do |config|
          dynamic_config = Config::DynamicConfiguration.new(config)

          config.stormpath.application.href = dynamic_config.app.href
          config.stormpath.web.forgot_password.enabled = dynamic_config.forgot_password_enabled?
          config.stormpath.web.change_password.enabled = dynamic_config.change_password_enabled?
          config.stormpath.web.facebook_app_id = dynamic_config.facebook_app_id
          config.stormpath.web.facebook_app_secret = dynamic_config.facebook_app_secret
          config.stormpath.web.github_app_id = dynamic_config.github_app_id
          config.stormpath.web.github_app_secret = dynamic_config.github_app_secret
          config.stormpath.web.google_app_id = dynamic_config.google_app_id
          config.stormpath.web.linkedin_app_id = dynamic_config.linkedin_app_id
          config.stormpath.web.has_social_providers = dynamic_config.has_social_providers?
          config.stormpath.web.verify_email.enabled = dynamic_config.verify_email_enabled?
          config.stormpath.web.client_api = { enabled: dynamic_config.client_api_enabled,
                                              domain_name: dynamic_config.client_api_domain }
        end
      end

      def merged_config_hashes
        default_config_hash.deep_merge(user_defined_config_hash)
      end

      def default_config_hash
        Config::ReadFile.new(
          File.expand_path(DEFAULT_CONFIG_RELATIVE_FILE_PATH, __FILE__)
        ).hash
      end
    end

    def self.config
      @configuration ||= Configuration.new(
        Config::ReadFile.new(
          ::Rails.application.root.join('config/stormpath.yml')
        ).hash
      )
    end
  end
end
