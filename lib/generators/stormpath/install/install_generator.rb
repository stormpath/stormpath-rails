require 'rails/generators/base'
require 'rails/generators/active_record'

module Stormpath
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def create_stormpath_initializer
        copy_file 'stormpath.rb', 'config/initializers/stormpath.rb'
      end
    end
  end
end