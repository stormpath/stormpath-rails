require 'spec_helper'

describe Stormpath::Rails::Configuration do

  context 'when id_site is not specified' do
    before do
      Stormpath::Rails.configure do |config|
        config.id_site = {}
      end
    end

    it 'defaults to false' do
      expect(Stormpath::Rails.config.id_site.enabled).to eq false
    end
  end

  context 'when is_site is set to true' do
    before do
      Stormpath::Rails.configure do |config|
        config.id_site = { enabled: true }
      end
    end

    it 'returns true' do
      expect(Stormpath::Rails.config.id_site.enabled).to eq true
    end
  end

  context 'when expand_custom_data is not specified' do
    it 'defaults to false' do
      expect(Stormpath::Rails.config.expand_custom_data).to eq true
    end
  end

  context 'when enable forgot password is specified' do
    before do
      Stormpath::Rails.configure do |config|
        config.enable_forgot_password = true
      end
    end

    it "returns configured value" do
      expect(Stormpath::Rails.config.enable_forgot_password).to eq true
    end
  end

  context 'when enable forgot password is specified' do
    before do
      Stormpath::Rails.configure do |config|
        config.verify_email = true
      end
    end

    it "returns configured value" do
      expect(Stormpath::Rails.config.verify_email).to eq true
    end
  end
end