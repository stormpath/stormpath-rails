module Stormpath
  module Rails
    InvalidConfiguration = Class.new(ArgumentError)

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
          config.stormpath.application.href = Config::ApplicationResolution.new(
            config.stormpath.application.href,
            config.stormpath.application.name
          ).app_href

          # Temporarily enable the features until the Ruby SDK gets the support for PasswordPolicies
          config.stormpath.web.forgot_password.enabled = true
          config.stormpath.web.change_password.enabled = true
        end
      end

      def merged_config_hashes
        default_config_hash.deep_merge(user_defined_config_hash)
      end

      def default_config_hash
        Config::ReadFile.new(
          File.expand_path('../../../../config/default_config.yml', __FILE__)
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
