require 'rails/generators/base'
require 'rails/generators/active_record'

module Stormpath
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      include ::Rails::Generators::Migration
      source_root File.expand_path('../templates', __FILE__)

      def create_stormpath_configuration_file
        copy_file 'stormpath.rb', 'config/initializers/stormpath.rb'
      end

      def inject_stormpath_into_application_controller
        inject_into_class(
          'app/controllers/application_controller.rb',
          ApplicationController,
          "  include Stormpath::Rails::Controller\n"
        )
      end

      def create_user_model
        if File.exist?(destination_root + '/app/models/user.rb')
          inject_into_file(
            'app/models/user.rb',
            "include Stormpath::Rails::User\n\n",
            after: "class User < ActiveRecord::Base\n"
          )
        else
          copy_file 'user.rb', 'app/models/user.rb'
        end
      end

      def create_stormpath_migration
        if user_table_exists?
          create_add_columns_migration
        else
          copy_migration 'create_users.rb'
        end
      end

      private

      def create_add_columns_migration
        return unless migration_needed?

        config = {
          new_columns: new_columns,
          new_indexes: new_indexes
        }

        copy_migration('add_stormpath_to_users.rb', config)
      end

      def migration_needed?
        new_columns.any? || new_indexes.any?
      end

      def new_columns
        @new_columns ||= {
          email: 't.string :email, null: false',
          given_name: 't.string :given_name, null: false',
          surname: 't.string :surname, null: false'
        }.reject { |column| existing_users_columns.include?(column.to_s) }
      end

      def new_indexes
        @new_indexes ||= {
          index_users_on_email: 'add_index :users, :email'
        }.reject { |index| existing_users_indexes.include?(index.to_s) }
      end

      def user_table_exists?
        ActiveRecord::Base.connection.table_exists?(:users)
      end

      def copy_migration(migration_name, config = {})
        return if migration_exists?(migration_name)
        migration_template(
          "db/migrate/#{migration_name}",
          "db/migrate/#{migration_name}",
          config
        )
      end

      def migration_exists?(name)
        existing_migrations.include?(name)
      end

      def existing_migrations
        @existing_migrations ||= Dir.glob('db/migrate/*.rb').map do |file|
          migration_name_without_timestamp(file)
        end
      end

      def migration_name_without_timestamp(file)
        file.sub(%r{^.*(db/migrate/)(?:\d+_)?}, '')
      end

      # for generating a timestamp when using `create_migration`
      def self.next_migration_number(dir)
        ActiveRecord::Generators::Base.next_migration_number(dir)
      end

      def existing_users_columns
        ActiveRecord::Base.connection.columns(:users).map(&:name)
      end

      def existing_users_indexes
        ActiveRecord::Base.connection.indexes(:users).map(&:name)
      end
    end
  end
end
