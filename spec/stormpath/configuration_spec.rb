require 'spec_helper'

describe Stormpath::Rails::Configuration, vcr: true do
  it 'configuration loads' do
    expect(configuration.web.register.form.fields.given_name.enabled).to be(true)
  end
end
