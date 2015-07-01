require "spec_helper"
require "generators/stormpath/install/install_generator"

class Rails::Application; end
class MyApp::Application < Rails::Application; end

describe Stormpath::Generators::InstallGenerator do
  destination File.expand_path('../../../../../tmp/tests', __FILE__)
  before { prepare_destination }
end
