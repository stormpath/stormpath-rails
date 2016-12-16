require 'spec_helper'

describe Stormpath::Rails::Client, vcr: true do
  let(:default_base_url) { 'https://api.stormpath.com/v1' }
  let(:custom_base_url) { 'https://eu.stormpath.io' }
  let(:stormpath_client) { Stormpath::Rails::Client }
  let(:api_key) { Stormpath::Rails::ApiKey.new }

  describe 'base url set' do
    before do
      stormpath_client.connection = nil
      allow(stormpath_client).to receive(:base_url).and_return(custom_base_url)
    end

    it 'should instantiate client with custom base url set in data store' do
      expect(Stormpath::Rails::Client.client.data_store.base_url).to eq custom_base_url
    end
  end

  describe 'base url not set' do
    before { stormpath_client.connection = nil }

    it 'should instantiate client with default base url set in data store' do
      expect(Stormpath::Rails::Client.client.data_store.base_url).to eq default_base_url
    end
  end
end
