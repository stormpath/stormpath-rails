require 'rails/generators/base'
require 'rails/generators/active_record'

module Stormpath
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      def create_stormpath_configuration_file
        copy_file 'default_config.yml', 'config/stormpath.yml'
      end

      def inject_stormpath_into_application_controller
        inject_into_class(
          'app/controllers/application_controller.rb',
          ApplicationController,
          "  include Stormpath::Rails::Controller\n"
        )
      end
    end
  end
end
