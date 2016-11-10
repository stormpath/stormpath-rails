require 'spec_helper'

describe 'Email Verification GET', type: :request, vcr: true do
  let(:response_body) { JSON.parse(response.body) }
  let(:application) { test_application }
  let(:test_dir_with_verification) do
    Stormpath::Rails::Client.client.directories.create(name: 'rails test dir with verification')
  end
  let(:account) { test_dir_with_verification.accounts.create(account_attrs) }
  let(:account_attrs) { FactoryGirl.attributes_for(:account) }
  let(:sptoken) { account.email_verification_token.token }

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
    def json_verify_get(attrs = {})
      get '/verify', attrs, 'HTTP_ACCEPT' => 'application/json'
    end

    context 'valid data' do
      it 'return 200 OK' do
        json_verify_get(sptoken: sptoken)
        expect(response.status).to eq(200)
        expect(response.body).to eq('')
      end

      context 'with auto login enabled' do
        before do
          allow(configuration.web.register).to receive(:auto_login).and_return(true)
        end

        it 'return 200 OK and sets cookies' do
          json_verify_get(sptoken: sptoken)
          expect(response.status).to eq(200)
          expect(response.body).to eq('')
          expect(response.cookies['access_token']).to be
          expect(response.cookies['refresh_token']).to be
        end
      end
    end

    context 'invalid data' do
      it 'return 404 OK' do
        json_verify_get(sptoken: 'invalid-sptoken')
        expect(response.status).to eq(404)
        expect(response_body['message']).to eq('The requested resource does not exist.')
      end
    end

    context 'no data' do
      it 'return 400' do
        json_verify_get
        expect(response.status).to eq(400)
        expect(response_body['message']).to eq('sptoken parameter not provided.')
      end
    end
  end
end
