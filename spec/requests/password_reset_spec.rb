require 'spec_helper'

describe 'Password reset', type: :request do
  let(:application) { Stormpath::Rails::Client.application }

  let(:account) { application.accounts.create(account_info) }

  let(:password_reset_token) { application.password_reset_tokens.create(email: account.email).token }

  let(:account_info) do
    {
      email: 'test@example.com',
      givenName: 'Ruby SDK',
      password: 'P@$$w0rd',
      surname: 'SDK',
      username: 'rubysdk'
    }
  end

  it 'should be able to validate token' do
    get "/forgot/change?sptoken=#{password_reset_token}"

    expect(response).to be_success
    expect(response.body).to include("Change Your Password")
  end

  it 'should be decline invalid token' do
    get "/forgot/change?sptoken=123"

    expect(response).to be_success
    expect(response.body).to include("Password Reset Failed")
  end
end
