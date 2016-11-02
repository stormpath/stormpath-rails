require 'spec_helper'

describe 'IdSiteLogin GET', type: :request, vcr: true do
  let(:application) { Stormpath::Rails::Client.application }
  Timecop.freeze(Time.zone.now) do
    let(:time) { Time.zone.now.to_i }
  end
  let(:cb_uri) { '/id_site_result' }
  let(:path) { '' }
  let(:tenant_name) { application.tenant.name }
  let(:tenant_domain) { "https://#{tenant_name}.id.stormpath.io" }
  let(:api_key_secret) { ENV['STORMPATH_API_KEY_SECRET'] }
  let(:aud) { ENV['STORMPATH_API_KEY_ID'] }
  let(:account) { application.accounts.create(account_attrs) }
  let(:account_attrs) { FactoryGirl.attributes_for(:account) }
  let(:jwt_response) do
    JWT.encode(
      {
        'iss' => tenant_domain,
        'sub' => account.href,
        'aud' => aud,
        'exp' => time + 1.minute.to_i,
        'iat' => time,
        'jti' => 'JX5HSMmEAevFBKJx4FfC3',
        'irt' => '5fbb73e7-f81b-41f2-8031-b08750da6298',
        'state' => '',
        'isNewSub' => false,
        'status' => 'AUTHENTICATED',
        'cb_uri' => 'http://localhost:3000/id_site_result'
      },
      api_key_secret,
      'HS256'
    )
  end

  before do
    allow(web_config.id_site).to receive(:enabled).and_return(true)
    Rails.application.reload_routes!
  end

  after do
    account.delete if account
    allow(web_config.id_site).to receive(:enabled).and_return(false)
    Rails.application.reload_routes!
  end

  describe 'HTTP_ACCEPT=text/html' do
    context 'successfull login' do
      it 'should redirect' do
        get '/id_site_result', jwtResponse: jwt_response
        expect(response).to redirect_to('/')
        expect(response.status).to eq(302)
      end
    end

    context 'invalid jwt' do
      describe 'expired' do
        let(:time) { Time.zone.now.to_i - 10.minutes }

        it 'should render flash error' do
          get '/id_site_result', jwtResponse: jwt_response
          expect(controller).to set_flash[:error].now
        end
      end

      describe 'bad signature' do
        let(:api_key_secret) { 'badapikeysecret' }

        it 'should render flash error' do
          get '/id_site_result', jwtResponse: jwt_response
          expect(controller).to set_flash[:error].now
        end
      end
    end
  end

  describe 'application/json' do
    let(:headers) do
      {
        'ACCEPT' => 'application/json'
      }
    end

    context 'successfull login' do
      it 'should respond with ok' do
        get '/id_site_result', { jwtResponse: jwt_response }, headers
        expect(response.status).to eq(200)
      end

      it 'should respond with the logged in account' do
        get '/id_site_result', { jwtResponse: jwt_response }, headers
        expect(response.body).to include('account')
      end
    end

    context 'invalid jwt' do
      describe 'expired' do
        let(:time) { Time.zone.now.to_i - 10.minutes }

        it 'should raise error' do
          get '/id_site_result', { jwtResponse: jwt_response }, headers
          expect(response.body).to include('message', 'Token is invalid')
        end
      end

      describe 'bad signature' do
        let(:api_key_secret) { 'badapikeysecret' }

        it 'should render flash error' do
          get '/id_site_result', { jwtResponse: jwt_response }, headers
          expect(response.body).to include('message', 'Signature verification raised')
        end
      end
    end
  end
end
