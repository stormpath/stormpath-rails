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

      # :base_path
      # :oauth2
      # :produces
      # :github
      # :linkedin
      # :me

      CONFIGURATION_ACCESSORS = [
        :login,
        :logout,
        :register,
        :access_token_cookie,
        :refresh_token_cookie,
        :id_site,
        :api_key,
        :application,
        :verify_email,
        :forgot_password,
        :change_password,
        :facebook,
        :google,
        :produces
      ]

      CONFIGURATION_ACCESSORS.each do |action|
        define_method("#{action}=") do |options|
          klass = user_config_class(action)
          instance_variable_set("@#{action}", klass.new(options))
        end

        define_method("#{action}") do |&block|
          action_value = instance_variable_get("@#{action}")

          if action_value.nil?
            klass = user_config_class(action)
            instance_variable_set("@#{action}", klass.new())
          end

          if block
            block.call(instance_variable_get("@#{action}"))
          end

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
    def self.configure
      yield(config)
    end
  end
end
