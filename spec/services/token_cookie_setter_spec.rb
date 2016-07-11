require 'spec_helper'

describe Stormpath::Rails::TokenCookieSetter, vcr: true, type: :service do
  let(:account) { create_test_account }

  let(:password_grant_request) do
    Stormpath::Oauth::PasswordGrantRequest.new(account.email, 'Password1337')
  end

  let(:application) { Stormpath::Rails::Client.application }

  let(:auth_result) do
    application.authenticate_oauth(password_grant_request)
  end

  let(:cookie_jar) { {} }

  let(:token_cookie_setter) do
    Stormpath::Rails::TokenCookieSetter.new(cookie_jar, auth_result)
  end

  after { account.delete }

  before do
    allow(JWT::Verify).to receive(:verify_expiration).and_return(nil)
  end

  def expiration_from_token(token)
    Time.zone.at(JWT.decode(token, ENV['STORMPATH_API_KEY_SECRET']).first['exp'])
  end

  describe 'default setup' do
    it 'sets the access token properly' do
      token_cookie_setter.call
      expect(cookie_jar['access_token']).to eq(
        value: auth_result.access_token,
        expires: expiration_from_token(auth_result.access_token),
        httponly: true,
        path: '/',
        secure: false
      )
    end

    it 'sets the refresh_token properly' do
      token_cookie_setter.call
      expect(cookie_jar['refresh_token']).to eq(
        value: auth_result.refresh_token,
        expires: expiration_from_token(auth_result.refresh_token),
        httponly: true,
        path: '/',
        secure: false
      )
    end
  end

  describe 'with httponly set to false in config' do
    before do
      allow(web_config.access_token_cookie).to receive(:http_only).and_return(false)
      allow(web_config.refresh_token_cookie).to receive(:http_only).and_return(false)
    end

    it 'should not return the httponly flag on access token' do
      token_cookie_setter.call
      expect(cookie_jar['access_token'][:httponly]).not_to be
    end

    it 'should not return the httponly flag on refresh token' do
      token_cookie_setter.call
      expect(cookie_jar['refresh_token'][:httponly]).not_to be
    end
  end

  describe 'with path set to /home in config' do
    before do
      allow(web_config.access_token_cookie).to receive(:path).and_return('/home')
      allow(web_config.refresh_token_cookie).to receive(:path).and_return('/home')
    end

    it 'should return /home as path on access token' do
      token_cookie_setter.call
      expect(cookie_jar['access_token'][:path]).to eq('/home')
    end

    it 'should return /home as path on refresh token' do
      token_cookie_setter.call
      expect(cookie_jar['refresh_token'][:path]).to eq('/home')
    end
  end

  describe 'with domain set to stormpath.com in config' do
    before do
      allow(web_config.access_token_cookie).to receive(:domain).and_return('stormpath.com')
      allow(web_config.refresh_token_cookie).to receive(:domain).and_return('stormpath.com')
    end

    it 'should return stormpath.com as domain' do
      token_cookie_setter.call
      expect(cookie_jar['access_token'][:domain]).to eq('stormpath.com')
    end

    it 'should return stormpath.com as domain' do
      token_cookie_setter.call
      expect(cookie_jar['refresh_token'][:domain]).to eq('stormpath.com')
    end
  end
end
