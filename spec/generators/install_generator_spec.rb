require "active_support/core_ext/class/attribute_accessors"
require "generator_spec/test_case"
require "generators/stormpath/rails/install/install_generator"

describe Stormpath::Rails::Generators::InstallGenerator do
  include GeneratorSpec::TestCase
  destination File.expand_path("../tmp", __FILE__)

  before(:all) do
    prepare_destination
    run_generator
  end

  it "creates configuration file" do
    assert_file "config/stormpath.yml", "common:\n  stormpath_url: <%= ENV['STORMPATH_URL'] %>\n  #application: https://api.stormpath.com/v1/applications/<application id>\n\ndevelopment:\n  root: https://api.stormpath.com/v1/directories/<root directory id>\n\ntest:\n  root: https://api.stormpath.com/v1/directories/<root directory id>\n\nproduction:\n  root: https://api.stormpath.com/v1/directories/<root directory id>\n"
  end
end
