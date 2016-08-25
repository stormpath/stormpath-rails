require 'spec_helper'

describe Stormpath::Rails::DeleteAccessToken, vcr: true, type: :service do
  let(:account) { create_test_account }

  let(:password_grant_request) do
    Stormpath::Oauth::PasswordGrantRequest.new(account.email, 'Password1337')
  end

  let(:application) { Stormpath::Rails::Client.application }

  let(:access_token_authentication_result) do
    application.authenticate_oauth(password_grant_request)
  end

  let(:access_token) { access_token_authentication_result.access_token }

  let(:expired_token) { 'eyJraWQiOiI2VTRIWk1IR0VZMEpHV1ZITjBVVU81QkdXIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiI0MTFwUFh6QlQ1Qmo4ckM2VVZBbGRQIiwiaWF0IjoxNDY0MTc3NzMyLCJpc3MiOiJodHRwczovL2FwaS5zdG9ybXBhdGguY29tL3YxL2FwcGxpY2F0aW9ucy8zblpsTEtWTUlPUHU3MVlDN1RGUjBvIiwic3ViIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hY2NvdW50cy80MDMxTkF2UU9HNEZJMldXSjhRNjExIiwiZXhwIjoxNDY0MTgxMzMyLCJydGkiOiI0MTFwUFVmNllVc2tXMjZGSUZKVjFMIn0.ltcEQqkVnMutBQItQehVn2ckXwsxnBjfTucFIuoGVNY' }

  before do
    account
    access_token_authentication_result
  end

  after { delete_test_account }

  it 'deletes the access token' do
    expect do
      Stormpath::Rails::DeleteAccessToken.new(access_token).call
    end.to change { account.access_tokens.count }.from(1).to(0)
  end

  it 'silently fails if token is expired' do
    expect { Stormpath::Rails::DeleteAccessToken.new(expired_token).call }.not_to raise_error
  end

  it 'silently fails if token is nil' do
    expect { Stormpath::Rails::DeleteAccessToken.new(nil).call }.not_to raise_error
  end
end
