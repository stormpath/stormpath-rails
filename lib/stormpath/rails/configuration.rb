module Stormpath
  module Rails
    class Configuration
      attr_accessor :api_key_file, :secret_key, :application, :expand_custom_data, :id_site, :user_model, :verify_email,
        :enable_forgot_password

      def initialize
        @id_site = false
        @expand_custom_data = true
        @verify_email = false
        @enable_forgot_password = false
      end

      def user_model
        @user_model ||= ::User
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
      yield config
    end
  end
end