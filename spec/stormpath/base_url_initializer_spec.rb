require 'spec_helper'

describe Stormpath::Rails::BaseUrlInitializer, vcr: true do
  let(:base_url_initializer) { Stormpath::Rails::BaseUrlInitializer.call(app_href) }

  describe 'application href' do
    context 'when set to default' do
      let(:app_href) { 'https://api.stormpath.com/v1/applications/XYZ' }

      it 'base url should equal host' do
        expect(base_url_initializer).to eq 'https://api.stormpath.com/v1'
      end
    end

    context 'when set to enterprise' do
      let(:app_href) { 'https://enterprise.stormpath.io/v1/applications/XYZ' }

      it 'base url should equal host' do
        expect(base_url_initializer).to eq 'https://enterprise.stormpath.io/v1'
      end
    end

    context 'when not set' do
      let(:app_href) { '' }

      it 'should raise an error' do
        expect { base_url_initializer }.to raise_error(Stormpath::Rails::InvalidConfiguration)
      end
    end
  end
end
