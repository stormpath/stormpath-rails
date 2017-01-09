require 'spec_helper'

describe Stormpath::Rails::Config::MultitenancyVerification, vcr: true do
  let(:verification) do
    Stormpath::Rails::Config::MultitenancyVerification.new(configuration.config_object.stormpath.web)
  end

  context 'configuration set properly' do
    before do
      allow(configuration.web.multi_tenancy).to receive(:enabled).and_return(true)
      allow(configuration.web.multi_tenancy).to receive(:strategy).and_return('subdomain')
      allow(configuration.web).to receive(:domain_name).and_return('example.com')
    end

    it 'should return' do
      expect { verification.call }.not_to raise_error
    end
  end

  context 'configuration not set properly' do
    before { allow(configuration.web.multi_tenancy).to receive(:enabled).and_return(true) }

    context 'strategy invalid' do
      before do
        allow(configuration.web.multi_tenancy).to receive(:strategy).and_return('invalid')
        allow(configuration.web).to receive(:domain_name).and_return('example.com')
      end

      it 'should raise InvalidConfiguration' do
        expect { verification.call }.to raise_error(Stormpath::Rails::InvalidConfiguration)
      end
    end

    context 'domain_name invalid' do
      before do
        allow(configuration.web.multi_tenancy).to receive(:strategy).and_return('stormpath')
        allow(configuration.web).to receive(:domain_name).and_return(nil)
      end

      it 'should raise InvalidConfiguration' do
        expect { verification.call }.to raise_error(Stormpath::Rails::InvalidConfiguration)
      end
    end
  end
end
