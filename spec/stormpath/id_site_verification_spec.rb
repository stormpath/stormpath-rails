require 'spec_helper'

describe Stormpath::Rails::Config::IdSiteVerification, vcr: true do
  let(:verification) do
    Stormpath::Rails::Config::IdSiteVerification.new(configuration.config_object.stormpath.web)
  end

  context 'configuration set properly' do
    before do
      allow(configuration.web.id_site).to receive(:enabled).and_return(true)
      allow(configuration.web.callback).to receive(:enabled).and_return(true)
    end

    it 'should return' do
      expect { verification.call }.not_to raise_error
    end
  end

  context 'configuration not set properly' do
    before { allow(configuration.web.id_site).to receive(:enabled).and_return(true) }

    context 'callback not enabled' do
      before { allow(configuration.web.callback).to receive(:enabled).and_return(false) }

      it 'should raise InvalidConfiguration' do
        expect { verification.call }.to raise_error(Stormpath::Rails::InvalidConfiguration)
      end
    end
  end
end
