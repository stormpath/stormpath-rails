require 'spec_helper'

describe Stormpath::Rails::DeleteRefreshToken, vcr: true, type: :service do
  let(:account) { create_test_account.account }

  let(:password_grant_request) { Stormpath::Oauth::PasswordGrantRequest.new('jlc@example.com', 'Password1337') }

  let(:application) { Stormpath::Rails::Client.application }

  let(:access_token_authentication_result) do
    application.authenticate_oauth(password_grant_request)
  end

  let(:refresh_token) { access_token_authentication_result.refresh_token }

  let(:expired_token) { "eyJraWQiOiI2VTRIWk1IR0VZMEpHV1ZITjBVVU81QkdXIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiI0MTFwUFh6QlQ1Qmo4ckM2VVZBbGRQIiwiaWF0IjoxNDY0MTc3NzMyLCJpc3MiOiJodHRwczovL2FwaS5zdG9ybXBhdGguY29tL3YxL2FwcGxpY2F0aW9ucy8zblpsTEtWTUlPUHU3MVlDN1RGUjBvIiwic3ViIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hY2NvdW50cy80MDMxTkF2UU9HNEZJMldXSjhRNjExIiwiZXhwIjoxNDY0MTgxMzMyLCJydGkiOiI0MTFwUFVmNllVc2tXMjZGSUZKVjFMIn0.ltcEQqkVnMutBQItQehVn2ckXwsxnBjfTucFIuoGVNY" }

  before {
    account
    access_token_authentication_result
  }

  after { delete_test_account }

  it 'deletes the access token' do
    expect {
      Stormpath::Rails::DeleteRefreshToken.new(refresh_token).call
    }.to change { account.refresh_tokens.count }.from(1).to(0)
  end

  it 'silently fails if token is expired' do
    expect { Stormpath::Rails::DeleteRefreshToken.new(expired_token).call }.not_to raise_error
  end

  it 'silently fails if token is nil' do
    expect { Stormpath::Rails::DeleteRefreshToken.new(nil).call }.not_to raise_error
  end
end
