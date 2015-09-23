require "spec_helper"
require "generators/stormpath/install/install_generator"

describe Stormpath::Generators::InstallGenerator, type: :generator do
  describe "initializer" do
    it "is copied to the application" do
      provide_existing_application_controller

      run_generator
      initializer = file("config/initializers/stormpath.rb")

      expect(initializer).to exist
      expect(initializer).to have_correct_syntax
      expect(initializer).to contain("Stormpath::Rails.configure do |config|")
    end
  end

  describe "application controller" do
    it "includes Stormpath::Rails::Controller" do
      provide_existing_application_controller

      run_generator
      application_controller = file("app/controllers/application_controller.rb")

      expect(application_controller).to have_correct_syntax
      expect(application_controller).to contain("include Stormpath::Rails::Controller")
    end
  end

  describe "user model" do
    context "no existing user class" do
      it "creates a user class including Stormpath::Rails::User" do
        provide_existing_application_controller

        run_generator
        user_class = file("app/models/user.rb")

        expect(user_class).to exist
        expect(user_class).to have_correct_syntax
        expect(user_class).to contain("Stormpath::Rails::User")
      end
    end
  end

  context "user class already exists" do
    it "includes Stormpath::Rails::User" do
      provide_existing_application_controller
      provide_existing_user_class

      run_generator
      user_class = file("app/models/user.rb")

      expect(user_class).to exist
      expect(user_class).to have_correct_syntax
      expect(user_class).to contain("include Stormpath::Rails::User")
    end
  end

  describe "user migration" do
    context "create users migration already exists" do
      it "does not copy the migration" do
        provide_existing_application_controller
        
        allow(ActiveRecord::Base.connection).to receive(:table_exists?).
          with(:users).
          and_return(false)

        allow(Dir).to receive(:glob). 
          and_return(["create_users.rb"])

        run_generator
        migration = migration_file("db/migrate/create_users.rb")

        expect(migration).not_to exist
      end
    end

    context "users table does not exist" do
      it "creates a migration to create the users table" do
        provide_existing_application_controller

        allow(ActiveRecord::Base.connection).to receive(:table_exists?).
          with(:users).
          and_return(false)

        run_generator
        migration = migration_file("db/migrate/create_users.rb")

        expect(migration).to exist
        expect(migration).to have_correct_syntax
        expect(migration).to contain("create_table :users")
      end
    end
 
    context "existing users table with all stormpath columns and indexes" do
      it "does not create a migration" do
        provide_existing_application_controller

        run_generator
        create_migration = migration_file("db/migrate/create_users.rb")
        add_migration = migration_file("db/migrate/add_stormpath_to_users.rb")

        expect(create_migration).not_to exist
        expect(add_migration).not_to exist
      end
    end

    context "existing users table missing some columns and indexes" do
      it "create a migration to add missing columns and indexes" do
        provide_existing_application_controller

        Struct.new("Named", :name)
        existing_columns = [Struct::Named.new("email")]

        allow(ActiveRecord::Base.connection).to receive(:columns).
          with(:users).
          and_return(existing_columns)

        allow(ActiveRecord::Base.connection).to receive(:indexes).
          with(:users).
          and_return([])

        run_generator
        migration = migration_file("db/migrate/add_stormpath_to_users.rb")

        expect(migration).to exist
        expect(migration).to have_correct_syntax
        expect(migration).to contain("change_table :users")
        expect(migration).to contain("t.string :given_name")
        expect(migration).to contain("t.string :surname")
        expect(migration).to contain("add_index :users, :email")
        expect(migration).not_to contain("t.string :email")
      end
    end

  end
end
