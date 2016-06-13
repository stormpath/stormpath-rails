module Stormpath
  module Rails
    class Configuration
      def application
        config_object.stormpath.application
      end

      def web
        config_object.stormpath.web
      end

      def config_object
        @config_object ||= RecursiveOpenStruct.new(merged_config_hashes).tap do |config|
          # Temporarily enable the features until the Ruby SDK gets the support for PasswordPolicies
          config.stormpath.web.forgot_password.enabled = true
          config.stormpath.web.change_password.enabled = true
        end
      end

      def merged_config_hashes
        default_config_hash.merge(user_defined_config_hash)
      end

      def default_config_hash
        ConfigFile.new(:default).hash
      end

      def user_defined_config_hash
        ConfigFile.new(:user_defined).hash
      end
    end

    # Return a single instance of Configuration class
    # @return [Stormpath::Configuration] single instance
    def self.config
      @configuration ||= Configuration.new
    end

    def self.reload_config!
      @configuration = Configuration.new
    end
  end
end
