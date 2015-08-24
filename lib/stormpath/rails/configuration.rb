module Stormpath
  module Rails
    class Configuration
      attr_accessor :secret_key, :expand_custom_data, :user_model

      def initialize
        @expand_custom_data = true
      end

      def user_model
        @user_model ||= ::User
      end

      [:id_site, :api_key, :application, :verify_email, :forgot_password].each do |action|
        define_method("#{action}=") do |options|
          klass = user_config_class(action)
          instance_variable_set("@#{action}", klass.new(options))
        end

        define_method("#{action}") do
          instance_variable_get("@#{action}")
        end
      end

      private

      def user_config_class(action)
        UserConfig.const_get(action.to_s.camelize)
      end
    end

    # Return a single instance of Configuration class
    # @return [Stormpath::Configuration] single instance
    def self.config
      @configuration ||= Configuration.new
    end

    # Configure the settings for this module
    # @param [lambda] which will be passed isntance of configuration class
    def self.configure(config_data)
      config.id_site = config_data[:web][:id_site] if config_data[:web] && config_data[:web][:id_site]
      config.api_key = config_data[:client][:api_key] if config_data[:client] && config_data[:client][:api_key]
      config.application = config_data[:application] if config_data[:application]
      config.verify_email = config_data[:web][:verify_email] if config_data[:web] && config_data[:web][:verify_email]
      config.forgot_password = config_data[:web][:forgot_password] if config_data[:web] && config_data[:web][:forgot_password]
    end
  end
end