require 'spec_helper'

describe Stormpath::Rails::Configuration, vcr: true do
  let(:stormpath_config_class) { Stormpath::Rails::Configuration }

  let(:stormpath_rails_config) do
    stormpath_config_class.new(
      user_defined_config_hash
    )
  end

  let(:user_defined_config_hash) do
    Stormpath::Rails::ReadConfigFile.new(
      ::Rails.application.root.join('config/stormpath.yml')
    ).hash
  end

  it 'configuration loads' do # Smoke Test
    expect(configuration.web.register.form.fields.given_name.enabled).to be(true)
  end
end
