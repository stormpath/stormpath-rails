require 'spec_helper'
require 'generators/stormpath/install/install_generator'

describe Stormpath::Generators::InstallGenerator, type: :generator do
  describe 'initializer' do
    it 'is copied to the application' do
      provide_existing_application_controller

      run_generator
      initializer = file('config/stormpath.yml')

      expect(initializer).to exist
    end
  end

  describe 'application controller' do
    it 'includes Stormpath::Rails::Controller' do
      provide_existing_application_controller

      run_generator
      application_controller = file('app/controllers/application_controller.rb')

      expect(application_controller).to have_correct_syntax
      expect(application_controller).to contain('include Stormpath::Rails::Controller')
    end
  end
end
