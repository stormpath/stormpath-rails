require 'spec_helper'

describe Stormpath::Rails::Configuration do

  context 'when configuration data is not specified' do
    before do
      config_not_specified
    end

    it 'defaults to false' do
      expect(Stormpath::Rails.config.id_site.enabled).to eq false
      expect(Stormpath::Rails.config.forgot_password.enabled).to eq false
      expect(Stormpath::Rails.config.verify_email.enabled).to eq false
    end
  end

  context 'when id_site is set to true' do
    before do
      enable_id_site
    end

    it 'returns true' do
      expect(Stormpath::Rails.config.id_site.enabled).to eq true
    end
  end

  context 'when enable forgot is set to true' do
    before do
      enable_forgot_password
    end

    it "returns configured value" do
      expect(Stormpath::Rails.config.forgot_password.enabled).to eq true
    end
  end

  context 'when enable verify_email is set to true' do
    before do
      enable_verify_email
    end

    it "returns configured value" do
      expect(Stormpath::Rails.config.verify_email.enabled).to eq true
    end
  end
end