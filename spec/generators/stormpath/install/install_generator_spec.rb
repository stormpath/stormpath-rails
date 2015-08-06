require "spec_helper"
require "generators/stormpath/install/install_generator"

describe Stormpath::Generators::InstallGenerator, :generator do
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
end
