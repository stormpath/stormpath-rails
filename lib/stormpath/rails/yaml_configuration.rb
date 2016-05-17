module Stormpath
  module Rails
    class YamlConfiguration
      def initialize
        @expand_custom_data = true
      end

      def user_model
        @user_model ||= ::User
      end

      def application
        config_object.stormpath.application
      end

      def web
        config_object.stormpath.web
      end

      def config_object
        @config_object ||= RecursiveOpenStruct.new(merged_config_hashes)
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
    def self.yaml_config
      @yaml_configuration ||= YamlConfiguration.new
    end
  end
end
