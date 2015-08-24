module Stormpath
  module Rails
    class Configuration
      attr_accessor :api_key_file, :secret_key, :application, :expand_custom_data, :user_model, :verify_email,
        :enable_forgot_password

      def initialize
        @expand_custom_data = true
        @verify_email = false
        @enable_forgot_password = false
      end

      def user_model
        @user_model ||= ::User
      end

      def id_site=(options)
        @id_site = UserConfig::IdSite.new(options)
      end

      def id_site
        @id_site ||= UserConfig::IdSite.new
      end

      def api_key=(options)
        @api_key = UserConfig::ApiKey.new(options)
      end

      def api_key
        @api_key ||= UserConfig::ApiKey.new
      end

      def application=(options)
        @application = UserConfig::Application.new(options)
      end

      def application
        @application ||= UserConfig::Application.new
      end

      def verify_email=(options)
        @verify_email = UserConfig::VerifyEmail.new(options)
      end

      def verify_email
        @verify_email ||= UserConfig::VerifyEmail.new
      end

      def forgot_password=(options)
        @forgot_password = UserConfig::ForgotPassword.new(options)
      end

      def forgot_password
        @forgot_password ||= UserConfig::ForgotPassword.new
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