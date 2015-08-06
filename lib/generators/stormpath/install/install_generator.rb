require 'rails/generators/base'
require 'rails/generators/active_record'

module Stormpath
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def create_stormpath_configuration_file
        copy_file 'stormpath.rb', 'config/initializers/stormpath.rb'
      end

      def inject_clearance_into_application_controller
        inject_into_class(
          "app/controllers/application_controller.rb",
          ApplicationController,
          "  include Stormpath::Rails::Controller\n"
        )
      end

      def create_user_model
        # the problem here is that is looking in the wrong root
        # if I put tmp/app it will work correctly
        if File.exists? 'app/models/user.rb'
          inject_into_file(
            "app/models/user.rb",
            "include Stormpath::Rails::User\n\n",
            after: "class User < ActiveRecord::Base\n"
          )
        else
          copy_file 'user.rb', 'app/models/user.rb'
        end
      end

      def create_stormpath_migration
        unless user_table_exists?
          copy migration 'create_users.rb'
        end
      end

      private

      def user_table_exists?
        ActiveRecord::Base.connection.table_exists?(:users)
      end
    end
  end
end