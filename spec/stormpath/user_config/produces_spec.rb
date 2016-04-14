require 'spec_helper'

describe Stormpath::Rails::UserConfig::Produces do
  let(:produces_config) { Stormpath::Rails::UserConfig::Produces.new }

  it 'should by default return the two default accept headers' do
    expect(produces_config.accepts).to eq(['application/json', 'text/html'])
  end

  it 'should return array when just one accept header is set' do
    produces_config.accepts = 'application/json'
    expect(produces_config.accepts).to eq(['application/json'])
  end

  it 'should return empty array when set to nil' do
    produces_config.accepts = nil
    expect(produces_config.accepts).to eq([])
  end
end
