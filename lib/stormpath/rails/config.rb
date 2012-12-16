module Stormpath
  module Rails
    class Config
      class << self
        attr_accessor :vars
      end

      def self.[](name)
        self.vars ||= YAML.load(ERB.new(File.read("#{::Rails.root}/config/stormpath.yml")).result)
        self.vars["common"].update(self.vars[::Rails.env])[name.to_s]
      end
    end
  end
end
