require 'rails/generators/base'

module Stormpath
  module Generators
    class MigrationGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      def create_migration_script
        copy_file 'stormpath.rake', 'lib/tasks/stormpath.rake'
      end
    end
  end
end
