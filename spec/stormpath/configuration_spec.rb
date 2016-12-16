require 'spec_helper'

describe Stormpath::Rails::Configuration, vcr: true do
  let(:stormpath_config_class) { Stormpath::Rails::Configuration }
  let(:stormpath_rails_config) { stormpath_config_class.new(user_defined_config_hash) }

  let(:user_defined_config_hash) do
    Stormpath::Rails::ReadConfigFile.new(
      ::Rails.application.root.join('config/stormpath.yml')
    ).hash
  end

  it 'configuration loads' do # Smoke Test
    expect(configuration.web.register.form.fields.given_name.enabled).to be(true)
  end

  it 'forgot password enabled by default configuration' do
    expect(configuration.web.forgot_password.enabled).to be(true)
  end

  it 'change password enabled by default configuration' do
    expect(configuration.web.change_password.enabled).to be(true)
  end

  describe 'set forgot password enabled to false' do
    let(:user_defined_config_hash) do
      {
        stormpath: {
          application: {
            href: Stormpath::Rails::Client.application.href
          },
          web: {
            forgot_password: {
              enabled: false
            }
          }
        }
      }.deep_stringify_keys!
    end

    it 'should return false after dynamic configuration' do
      expect(stormpath_rails_config.web.forgot_password.enabled).to be(false)
    end
  end

  describe 'set change password enabled to false' do
    let(:user_defined_config_hash) do
      {
        stormpath: {
          application: {
            href: Stormpath::Rails::Client.application.href
          },
          web: {
            change_password: {
              enabled: false
            }
          }
        }
      }.deep_stringify_keys!
    end

    it 'should return false after dynamic configuration' do
      expect(stormpath_rails_config.web.change_password.enabled).to be(false)
    end
  end

  describe 'app name set' do
    let(:user_defined_config_hash) do
      {
        stormpath: {
          application: {
            name: Stormpath::Rails::Client.application.name
          }
        }
      }.deep_stringify_keys!
    end

    it 'should set app href after dynamic configuration' do
      expect(stormpath_rails_config.application.href).to be(
        Stormpath::Rails::Client.application.href
      )
    end
  end

  describe 'base_path config' do
    let(:user_defined_config_hash) do
      {
        stormpath: {
          application: {
            href: Stormpath::Rails::Client.application.href
          },
          web: {
            base_path: base_url
          }
        }
      }.deep_stringify_keys!
    end

    context 'when nil' do
      let(:base_url) { nil }

      it 'should be nil' do
        expect(stormpath_rails_config.web.base_path).to be_nil
      end
    end

    context 'when set' do
      let(:base_url) { 'https://eu.stormpath.io' }

      it 'should be set' do
        expect(stormpath_rails_config.web.base_path).to eq base_url
      end
    end
  end
end
