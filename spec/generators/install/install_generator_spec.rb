require "spec_helper"
require "generators/stormpath/install/install_generator"

describe Stormpath::Generators::InstallGenerator, :type => :generator do
  destination File.expand_path('../../../../../tmp/tests', __FILE__)
  before { prepare_destination }

  describe "initializer" do
    it "is copied to the application" do

      run_generator
      initializer = file("config/initializers/stormpath.rb")

      expect(initializer).to exist
      expect(initializer).to have_correct_syntax
      expect(initializer).to contain("Stormpath::Rails.configure do |config|")
    end
  end
end
