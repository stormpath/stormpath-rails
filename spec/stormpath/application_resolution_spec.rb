require 'spec_helper'

describe Stormpath::Rails::Config::ApplicationResolution, vcr: true do
  let(:app_resolution_class) { Stormpath::Rails::Config::ApplicationResolution }
  let(:app_resolution) { app_resolution_class.new(app_href, app_name) }

  describe 'with defined href' do
    let(:app_name) { nil }

    describe 'mapped to an existing app' do
      let(:app_href) { Stormpath::Rails::Client.application.href }

      it 'retrieves href from href' do
        expect(app_resolution.app.href).to eq(app_href)
      end
    end

    describe 'with malformed href' do
      let(:app_href) { 'http://invalid-url.com' }
      it 'raises InvalidConfiguration' do
        expect { app_resolution.app }.to raise_error(Stormpath::Rails::InvalidConfiguration)
      end
    end

    describe 'mapped to a non-existing app' do
      let(:app_href) { 'https://api.stormpath.com/v1/applications/nonexistinghref99' }
      it 'raises InvalidConfiguration' do
        expect { app_resolution.app }.to raise_error(Stormpath::Rails::InvalidConfiguration)
      end
    end
  end

  describe 'with defined name' do
    let(:app_href) { nil }

    describe 'mapped to an existing app' do
      let(:app_name) { Stormpath::Rails::Client.application.name }

      it 'retrieves href from name' do
        expect(app_resolution.app.href).to eq(Stormpath::Rails::Client.application.href)
      end
    end

    describe 'mapped to a non-existing app' do
      let(:app_name) { '999-non-existing-app-999' }
      it 'raises InvalidConfiguration' do
        expect { app_resolution.app }.to raise_error(Stormpath::Rails::InvalidConfiguration)
      end
    end
  end

  describe 'without defining href or name' do
    let(:app_href) { nil }
    let(:app_name) { nil }

    describe 'if it has 2 apps mapped' do
      it 'retrieves href from name' do
        allow(app_resolution).to receive(:client_has_exactly_two_applications?).and_return(true)
        expect(app_resolution.app.href).to eq(Stormpath::Rails::Client.application.href)
      end
    end

    describe 'if it has more or less than 2 apps mapped' do
      it 'raises InvalidConfiguration' do
        allow(app_resolution).to receive(:client_has_exactly_two_applications?).and_return(false)
        expect { app_resolution.app }.to raise_error(Stormpath::Rails::InvalidConfiguration)
      end
    end
  end
end
