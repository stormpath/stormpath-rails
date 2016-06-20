require 'ammeter/rspec/generator/example.rb'
require 'ammeter/rspec/generator/matchers.rb'
require 'ammeter/init'

module GeneratorSpecHelpers
  TEMPLATE_PATH = File.expand_path('../../app_templates', __FILE__)

  def provide_existing_application_controller
    copy_to_generator_root('app/controllers', 'application_controller.rb')
  end

  private

  def copy_to_generator_root(destination, template)
    template_file = File.join(TEMPLATE_PATH, destination, template)
    destination = File.join(destination_root, destination)

    FileUtils.mkdir_p(destination)
    FileUtils.cp(template_file, destination)
  end
end

RSpec.configure do |config|
  config.include GeneratorSpecHelpers

  config.before(:example, :generator) do
    destination File.expand_path('../../../tmp', __FILE__)
    prepare_destination
  end
end
