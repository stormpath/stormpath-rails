require 'spec_helper'

describe Stormpath::Rails::Client, vcr: true do
  let(:default_base_url) { 'https://api.stormpath.com/v1' }
  let(:custom_base_url) { 'https://eu.stormpath.io/v1' }
  let(:stormpath_client) { Stormpath::Rails::Client }
  let(:api_key) { Stormpath::Rails::ApiKey.new }

  describe 'custom base url set' do
    before do
      stormpath_client.connection = nil
      allow(stormpath_client).to receive(:base_url).and_return(custom_base_url)
    end

    after { stormpath_client.connection = nil }

    it 'should instantiate client with custom base url set in data store' do
      expect(test_client.data_store.base_url).to eq custom_base_url
    end

    it 'should raise error if trying to fetch applications' do
      expect { test_client.applications }.to raise_error(Stormpath::Error, 'Authentication required.')
    end
  end

  describe 'base url not set' do
    it 'should instantiate client with default base url set in data store' do
      expect(test_client.data_store.base_url).to eq default_base_url
    end

    it 'should not raise error if trying to fetch applications' do
      expect { test_client.applications }.not_to raise_error
    end
  end

  describe 'default base url set' do
    before do
      stormpath_client.connection = nil
      allow(stormpath_client).to receive(:base_url).and_return(default_base_url)
    end

    it 'should instantiate client with default base url set in data store' do
      expect(test_client.data_store.base_url).to eq default_base_url
    end

    it 'should not raise error if trying to fetch applications' do
      expect { test_client.applications }.not_to raise_error
    end
  end
end
