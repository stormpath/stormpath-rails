require 'spec_helper'

describe Stormpath::Rails::YamlConfiguration, vcr: true do
  let(:configuration) { Stormpath::Rails.yaml_config }

  it 'configuration loads' do
    expect(configuration.web.register.form.fields.given_name.enabled).to be(true)
  end
end
