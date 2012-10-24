require "stormpath-rails/version"
require "stormpath-rails/client"
require "stormpath-rails/account"

module Stormpath
  module Rails
    class Config
      cattr_accessor :vars

      def self.[](name)
        self.vars ||= YAML.load(ERB.new(File.read("#{::Rails.root}/config/stormpath.yml")).result)
        self.vars["common"].update(self.vars[::Rails.env])[name.to_s]
      end
    end
  end
end
