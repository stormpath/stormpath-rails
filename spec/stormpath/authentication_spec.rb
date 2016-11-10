require 'spec_helper'

describe Stormpath::Rails::Controller, vcr: true, type: :request do
  shared_examples 'a restricting controller' do
    it 'should redirect to login uri' do
      get_profile
      expect(response).to redirect_to('/login?next=/me')
    end

    it 'should have status 302' do
      get_profile
      expect(response.status).to eq 302
    end
  end

  shared_examples 'a profile controller' do
    it 'should return account' do
      get_profile
      expect(JSON.parse(response.body)['account']['email']).to eq account.email
    end

    it 'should respond with 200' do
      get_profile
      expect(response.status).to eq 200
    end
  end

  let(:application) { test_application }
  let(:directory) { test_client.directories.first }
  let(:account_attrs) { FactoryGirl.attributes_for(:account) }
  let(:account) { application.accounts.create(account_attrs) }
  let(:application2) { test_client.applications.create(FactoryGirl.attributes_for(:application)) }
  let(:directory2) { test_client.directories.create(FactoryGirl.attributes_for(:directory)) }
  let(:map_another_directory) { map_account_store(application2, directory2, 0, true, true) }
  let(:account2) { application2.accounts.create(account_attrs) }
  let(:expired_token) do
    'eyJraWQiOiI2VTRIWk1IR0VZMEpHV1ZITjBVVU81QkdXIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiI0MTFwUFh6QlQ1Qmo4ckM2VVZBbGRQIiwiaWF0IjoxNDY0MTc3NzMyLCJpc3MiOiJodHRwczovL2FwaS5zdG9ybXBhdGguY29tL3YxL2FwcGxpY2F0aW9ucy8zblpsTEtWTUlPUHU3MVlDN1RGUjBvIiwic3ViIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hY2NvdW50cy80MDMxTkF2UU9HNEZJMldXSjhRNjExIiwiZXhwIjoxNDY0MTgxMzMyLCJydGkiOiI0MTFwUFVmNllVc2tXMjZGSUZKVjFMIn0.ltcEQqkVnMutBQItQehVn2ckXwsxnBjfTucFIuoGVNY'
  end
  let(:aquire_token) { application.authenticate_oauth(password_grant_request) }
  let(:access_token) { aquire_token.access_token }
  let(:api_key) { account.api_keys.create({}) }
  let(:encoded_api_key) { Base64.encode64("#{api_key.id}:#{api_key.secret}") }
  let(:get_profile) do
    get '/me', {}, header => value
  end

  after { account.delete }

  describe 'from cookies' do
    let(:header) { 'HTTP_COOKIE' }

    context 'without access token' do
      let(:value) { 'access_token=' }
      it_should_behave_like 'a restricting controller'
    end

    context 'expired access token' do
      let(:value) { "access_token=#{expired_token}" }
      it_should_behave_like 'a restricting controller'
    end

    context 'invalid issuer' do
      before do
        map_another_directory
        account2
      end
      let(:password_grant_request) do
        Stormpath::Oauth::PasswordGrantRequest.new(account2.email, 'Password1337')
      end
      let(:access_token) { aquire_token.access_token }
      let(:aquire_token) { application2.authenticate_oauth(password_grant_request) }
      let(:value) { "access_token=#{access_token}" }
      after do
        account2.delete
        directory2.delete
        application2.delete
      end
      it_should_behave_like 'a restricting controller'
    end

    context 'valid access token' do
      let(:password_grant_request) do
        Stormpath::Oauth::PasswordGrantRequest.new(account.email, 'Password1337')
      end
      let!(:value) { "access_token=#{access_token}" }
      it_should_behave_like 'a profile controller'
    end
  end

  describe 'basic auth' do
    let(:header) { 'Authorization' }

    context 'valid authorization_header' do
      let(:value) { "Basic #{encoded_api_key}" }
      it_should_behave_like 'a profile controller'
    end

    context 'without authorization_header' do
      let(:value) { 'Basic ' }
      it_should_behave_like 'a restricting controller'
    end

    context 'with just the api key id as the authorization_header' do
      let(:encoded_api_key) { Base64.encode64("#{api_key.id}:") }
      let(:value) { "Basic #{encoded_api_key}" }
      it_should_behave_like 'a restricting controller'
    end
  end

  describe 'bearer auth' do
    let(:header) { 'Authorization' }

    context 'without access token' do
      let(:value) { 'Bearer ' }
      it_should_behave_like 'a restricting controller'
    end

    context 'expired access token' do
      let(:value) { "Bearer #{expired_token}" }
      it_should_behave_like 'a restricting controller'
    end

    context 'invalid issuer' do
      before do
        map_another_directory
        account2
      end
      let(:password_grant_request) do
        Stormpath::Oauth::PasswordGrantRequest.new(account2.email, 'Password1337')
      end
      let(:access_token) { aquire_token.access_token }
      let(:aquire_token) { application2.authenticate_oauth(password_grant_request) }
      let(:value) { "Bearer #{access_token}" }
      after do
        account2.delete
        directory2.delete
        application2.delete
      end
      it_should_behave_like 'a restricting controller'
    end

    context 'valid access token' do
      let(:password_grant_request) do
        Stormpath::Oauth::PasswordGrantRequest.new(account.email, 'Password1337')
      end
      let!(:value) { "Bearer #{access_token}" }
      it_should_behave_like 'a profile controller'
    end
  end
end
