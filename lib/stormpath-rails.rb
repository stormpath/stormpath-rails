require "stormpath-rails/version"
require "stormpath-rails/client"
require "stormpath-rails/account"

module Stormpath
  module Rails
    class Config
      cattr_accessor :_variables

      def self.[](name)
        self._variables ||= YAML.load(ERB.new(File.read("#{::Rails.root}/config/stormpath.yml")).result)[::Rails.env]
        self._variables[name.to_s]
      end
    end
  end
end
