require 'spec_helper'

describe Stormpath::Rails::TokenAndCookiesCleaner, vcr: true, type: :service do
  let(:account) { create_test_account }

  let(:password_grant_request) do
    Stormpath::Oauth::PasswordGrantRequest.new(account.email, 'Password1337')
  end

  let(:application) { Stormpath::Rails::Client.application }

  let(:access_token_authentication_result) do
    application.authenticate_oauth(password_grant_request)
  end

  let(:access_token) { access_token_authentication_result.access_token }

  let(:refresh_token) { access_token_authentication_result.refresh_token }

  let(:mocked_cookies_session) do
    {
      'access_token' => access_token,
      'refresh_token' => refresh_token
    }
  end

  before do
    account
    access_token_authentication_result
  end

  after { delete_test_account }

  it 'deletes the access token' do
    expect do
      Stormpath::Rails::TokenAndCookiesCleaner.new(mocked_cookies_session).remove
    end.to change { account.access_tokens.count }.from(1).to(0)
  end

  it 'deletes the refresh token' do
    expect do
      Stormpath::Rails::TokenAndCookiesCleaner.new(mocked_cookies_session).remove
    end.to change { account.refresh_tokens.count }.from(1).to(0)
  end
end
