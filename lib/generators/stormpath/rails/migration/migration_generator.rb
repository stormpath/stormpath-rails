require "active_support/core_ext/string/inflections"

module Stormpath
  module Rails
    module Generators
      class MigrationGenerator < ::Rails::Generators::Base
        argument :model_name, type: :string, default: "user", banner: "Account model name"
        source_root File.expand_path('../../templates', __FILE__)

        def create_migration_file
          template "update_account_model.rb",
                   "db/migrate/#{Time.now.utc.strftime("%Y%m%d%H%M%S")}_add_stormpath_url_to_#{model_name.pluralize}.rb"
        end
      end
    end
  end
end
