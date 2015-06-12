module Stormpath
  class Configuration
    attr_accessor :api_key_file, :secret_key, :application, :expand_custom_data, :id_site

    def initialize
      @id_site = false
      @expand_custom_data = true
    end
  end

  # Return a single instance of Configuration class
  # @return [Stormpath::Configuration] single instance
  def self.conf
    @configuration ||= Configuration.new
  end

  # Configure the settings for this module
  # @param [lambda] which will be passed isntance of configuration class
  def self.configure
    yield conf
  end
end