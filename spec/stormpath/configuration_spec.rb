require 'spec_helper'

describe Stormpath::Rails::Configuration do

  let(:configuration) { Stormpath::Rails.config }

  context 'when configuration data is not specified' do
    before do
      config_not_specified
    end

    it 'defaults to false' do
      expect(configuration.id_site.enabled).to eq false
      expect(configuration.forgot_password.enabled).to eq false
      expect(configuration.verify_email.enabled).to eq false
    end
  end

  context 'when id_site is set to true' do
    before do
      enable_id_site
    end

    it 'returns true' do
      expect(configuration.id_site.enabled).to eq true
    end
  end

  context 'when enable forgot is set to true' do
    before do
      enable_forgot_password
    end

    it "returns configured value" do
      expect(configuration.forgot_password.enabled).to eq true
    end
  end

  context 'when enable verify_email is set to true' do
    before do
      enable_verify_email
    end

    it "returns configured value" do
      expect(configuration.verify_email.enabled).to eq true
    end
  end

  context 'when facebook is not set' do
    before do
      disable_facebook_login
    end

    it 'enabled is set to false' do
      expect(configuration.facebook.enabled?).to eq false
    end
  end

  context 'when facebook is set' do
    before do
      enable_facebook_login
    end

    it 'enabled is set to true' do
      expect(configuration.facebook.enabled?).to eq true 
    end
  end
end
