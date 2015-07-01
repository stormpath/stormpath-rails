require 'rails/generators/base'

module Stormpath
  module Generators
    class RoutesGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)
    end
  end
end