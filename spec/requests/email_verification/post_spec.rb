require 'spec_helper'

describe 'Email Verification POST', type: :request, vcr: true do
  let(:test_dir_with_verification) do
    Stormpath::Rails::Client.client.directories.get(
      ENV.fetch('STORMPATH_SDK_TEST_DIRECTORY_WITH_VERIFICATION_URL')
    )
  end

  let(:account) { test_dir_with_verification.accounts.create(account_attrs) }

  let(:account_attrs) do
    {
      email: 'example@test.com',
      given_name: 'Example',
      surname: 'Test',
      password: 'Pa$$W0RD',
      username: 'SirExample'
    }
  end

  before do
    account
    enable_email_verification
    Rails.application.reload_routes!
  end

  after do
    account.delete
  end

  context 'application/json' do
    def json_verify_post(attrs = {})
      post '/verify', attrs, 'HTTP_ACCEPT' => 'application/json'
    end

    context 'valid data' do
      it 'return 200 OK' do
        json_verify_post(email: account.email)
        expect(response.status).to eq(200)
      end

      it 'verification token' do
        json_verify_post(email: account.email)
        expect(account.email_verification_token).to be
      end
    end

    context 'invalid data' do
      it 'return 200 OK' do
        json_verify_post(email: 'non-existant-email@testable.com')
        expect(response.status).to eq(200)
      end
    end

    context 'no data' do
      it 'return 400' do
        json_verify_post
        expect(response.status).to eq(400)
      end
    end
  end
end
