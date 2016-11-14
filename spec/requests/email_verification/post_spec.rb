require 'spec_helper'

describe 'Email Verification POST', type: :request, vcr: true do
  let(:application) { test_application }
  let(:test_dir_with_verification) do
    Stormpath::Rails::Client.client.directories.create(FactoryGirl.attributes_for(:directory))
  end
  let(:account) { test_dir_with_verification.accounts.create(account_attrs) }
  let(:account_attrs) { FactoryGirl.attributes_for(:account) }

  before do
    enable_email_verification_for(test_dir_with_verification)
    map_account_store(application, test_dir_with_verification, 2, false, false)
    account
    enable_email_verification
    Rails.application.reload_routes!
  end

  after do
    account.delete
    test_dir_with_verification.delete
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
