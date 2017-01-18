require 'spec_helper'

describe 'Login POST', type: :request, vcr: true do
  let(:app_href) { URI Stormpath::Rails::Client.application.href }
  let(:account) { Stormpath::Rails::Client.application.accounts.create(account_attrs) }
  let(:mocked_account) { Stormpath::Social::Helpers.mocked_account(:facebook) }

  let(:account_attrs) { attributes_for(:account) }

  let(:provider_data) do
    {
      'providerData' => {
        'providerId' => 'facebook',
        'accessToken' => 'EAAPyFJXxH5sBADjKxB158QUAJq8UvPZAR0V36F8o0YTckSIwTxuE70XZCyol8GcoOURJBlS5ZCRrqbqZCOu7oJCM27ZAqfyMrmlcdsogFs3CCujSuZBwcroGI21v6LSK15cf1ui2fu64x1PwTIXtlXDzLheSl05QgZD'
      }
    }
  end

  before { account }

  before do
    Rails.application.reload_routes!
  end

  after { account.delete }

  def response_body
    JSON.parse(response.body)
  end

  describe 'HTTP_ACCEPT=text/html' do
    describe 'html is enabled' do
      context 'multitenancy disabled' do
        it 'successfull login' do
          post '/login', login: account_attrs[:email], password: account_attrs[:password]
          expect(response).to redirect_to('/')
          expect(response.status).to eq(302)
        end

        it 'failed login, wrong password' do
          post '/login', login: account_attrs[:email], password: 'WR00N6'
          expect(response.status).to eq(200)
          expect(response.body).to include('Invalid username or password')
        end
      end

      context 'multitenancy enabled' do
        let(:application) { test_client.applications.create(attributes_for(:application)) }
        let(:multitenancy_config) { configuration.web.multi_tenancy }
        let(:directory) { test_client.directories.create(attributes_for(:directory)) }
        let(:organization) { test_client.organizations.create(attributes_for(:organization)) }
        let(:multi_account_attrs) { attributes_for(:account) }
        let(:config) { Stormpath::Rails::Configuration }

        before do
          allow(multitenancy_config).to receive(:enabled).and_return(true)
          allow(multitenancy_config).to receive(:strategy).and_return('subdomain')
          allow(configuration.web).to receive(:domain_name).and_return('infinum.co')
          allow_any_instance_of(config).to receive(:application).and_return(application)
          map_account_store(application, directory, 0, true, false)
          map_account_store(application, organization, 11, false, false)
          map_organization_store(directory, organization, true)
          organization.accounts.create(multi_account_attrs)
        end

        after do
          organization.delete
          directory.delete
          application.delete
        end

        context 'existing organization' do
          context 'organization_name_key is in request.host' do
            let(:request_host) do
              { 'HTTP_HOST' => "#{organization.name_key}.#{configuration.web.domain_name}" }
            end

            it 'successfull login' do
              post '/login', { login: multi_account_attrs[:email], password: multi_account_attrs[:password] }, request_host
              expect(response.status).to eq(302)
              expect(response).to redirect_to('/')
            end
          end

          context 'organization_name_key is in request.body' do
            it 'successfull login' do
              post '/login', login: multi_account_attrs[:email], password: multi_account_attrs[:password], organization_name_key: organization.name_key
              expect(response.status).to eq(302)
              expect(response).to redirect_to('/')
            end
          end
        end

        context 'non-existing organization' do
          let(:request_host) do
            { 'HTTP_HOST' => "non-existing-rails-org.#{configuration.web.domain_name}" }
          end

          it 'should render the page for selecting an organization' do
            post '/login', { login: multi_account_attrs[:email], password: multi_account_attrs[:password] }, request_host
            expect(response.body).to include("Select your Organization")
            expect(response.status).to eq 200
          end
        end
      end
    end

    describe 'html is disabled' do
      before do
        allow(configuration.web).to receive(:produces) { ['application/json'] }
        Rails.application.reload_routes!
      end

      it 'returns 404' do
        post '/login', login: account_attrs[:email], password: account_attrs[:password]
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'HTTP_ACCEPT=application/json' do
    def json_login_post(attrs)
      post '/login', attrs, 'HTTP_ACCEPT' => 'application/json'
    end

    describe 'json is enabled' do
      context 'with username and password' do
        it 'successfull login should result with 200' do
          json_login_post(login: account_attrs[:email], password: account_attrs[:password])
          expect(response.status).to eq(200)
        end

        it 'successfull login with username should result with 200' do
          json_login_post(login: account_attrs[:username], password: account_attrs[:password])
          expect(response.status).to eq(200)
        end

        it 'successfull login should have content-type application/json' do
          json_login_post(login: account_attrs[:email], password: account_attrs[:password])
          expect(response.content_type.to_s).to eq('application/json')
        end

        it 'successfull login should match schema' do
          json_login_post(login: account_attrs[:email], password: account_attrs[:password])
          expect(response).to match_response_schema(:login_response, strict: true)
        end

        it 'successfull login should set cookies' do
          json_login_post(login: account_attrs[:email], password: account_attrs[:password])
          expect(response.cookies['access_token']).to be
          expect(response.cookies['refresh_token']).to be
        end

        it 'successful login should match json' do
          json_login_post(login: account_attrs[:email], password: account_attrs[:password])
          expect(response).to match_json <<-JSON
          {
             "account":{
                "href":"{string}",
                "username":"#{account.username}",
                "modifiedAt":"{date_time_iso8601}",
                "status":"ENABLED",
                "createdAt":"{date_time_iso8601}",
                "email":"#{account.email}",
                "middleName":null,
                "surname":"#{account.surname}",
                "givenName":"#{account.given_name}",
                "fullName":"#{account.given_name} #{account.surname}"
             }
          }
          JSON
        end

        it 'failed login, wrong password should result with 400' do
          json_login_post(login: account_attrs[:email], password: 'WR00N6')
          expect(response.status).to eq(400)
        end

        it 'failed login, wrong password should result with a message in the response body' do
          json_login_post(login: account_attrs[:email], password: 'WR00N6')

          expect(response_body['status']).to eq(400)
          expect(response_body['message']).to eq('Invalid username or password.')
        end
      end

      context 'with providerData' do
        it 'successfull login should result with 200' do
          stub_request(:post, "#{app_href}/accounts").to_return(status: 200)
          stub_request(:post, "#{app_href}/oauth/token").to_return(body: mocked_account)
          allow_any_instance_of(Stormpath::Rails::SocialLoginForm).to receive(:save!).and_return(mocked_account)
          allow_any_instance_of(Stormpath::Rails::AccountSerializer).to receive(:to_h).and_return(mocked_account)
          json_login_post(provider_data)
          expect(response.status).to eq(200)
        end
      end

      context 'multitenancy enabled, organization not set' do
        let(:multitenancy_config) { configuration.web.multi_tenancy }
        let(:create_controller) { Stormpath::Rails::Login::CreateController }
        let(:organization_form) { Stormpath::Rails::OrganizationForm }
        let(:subdomain) { 'invalid_name_key' }
        let(:domain) { 'stormpath.dev' }
        let(:request) do
          OpenStruct.new(scheme: 'http',
                         host: "#{subdomain}.#{domain}",
                         domain: domain,
                         subdomain: subdomain,
                         path: '/login')
        end
        before do
          allow(multitenancy_config).to receive(:enabled).and_return(true)
          allow(multitenancy_config).to receive(:strategy).and_return('subdomain')
          allow(configuration.web).to receive(:domain_name).and_return('stormpath.dev')
          allow_any_instance_of(create_controller).to receive(:req).and_return(request)
          allow_any_instance_of(create_controller).to receive(:organization_resolution?).and_return(true)
        end

        it 'should respond with 302 if organization found' do
          allow_any_instance_of(organization_form).to receive(:save!).and_return(true)
          allow_any_instance_of(create_controller).to receive(:subdomain_login_url).and_return('http://mocked-correct-name-key.stormpath.dev')
          post '/login',
               { organization_resolution: true, organization_name_key: 'name_key' },
               'HTTP_ACCEPT' => 'application/json'
          expect(response.status).to eq(302)
          expect(response).to redirect_to('http://mocked-correct-name-key.stormpath.dev')
        end

        it 'should respond with 400 if organization not found' do
          post '/login',
               { organization_resolution: true, organization_name_key: 'invalid' },
               'HTTP_ACCEPT' => 'application/json'
          expect(response.status).to eq(400)
          expect(response_body['message']).to eq('Organization could not be found')
        end
      end
    end

    describe 'json is disabled' do
      before do
        allow(configuration.web).to receive(:produces) { ['application/html'] }
        Rails.application.reload_routes!
      end

      it 'returns 404' do
        json_login_post(login: account_attrs[:email], password: account_attrs[:password])
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'HTTP_ACCEPT=nil' do
    def login_post_with_nil_http_accept(attrs)
      post '/login', attrs, 'HTTP_ACCEPT' => nil
    end

    describe 'json is enabled' do
      it 'successfull login should result with 200' do
        login_post_with_nil_http_accept(login: account_attrs[:email], password: account_attrs[:password])
        expect(response.status).to eq(200)
      end

      it 'successfull login with username should result with 200' do
        login_post_with_nil_http_accept(
          login: account_attrs[:username],
          password: account_attrs[:password]
        )
        expect(response.status).to eq(200)
      end

      it 'successfull login should have content-type application/json' do
        login_post_with_nil_http_accept(login: account_attrs[:email], password: account_attrs[:password])
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'successfull login should match schema' do
        login_post_with_nil_http_accept(login: account_attrs[:email], password: account_attrs[:password])
        expect(response).to match_response_schema(:login_response, strict: true)
      end

      it 'failed login, wrong password should result with 400' do
        login_post_with_nil_http_accept(login: account_attrs[:email], password: 'WR00N6')
        expect(response.status).to eq(400)
      end

      it 'failed login, wrong password should result with a message in the response body' do
        login_post_with_nil_http_accept(login: account_attrs[:email], password: 'WR00N6')

        expect(response_body['status']).to eq(400)
        expect(response_body['message']).to eq('Invalid username or password.')
      end
    end

    describe 'json is disabled' do
      before do
        allow(configuration.web).to receive(:produces) { ['text/html'] }
        Rails.application.reload_routes!
      end

      it 'returns 404' do
        login_post_with_nil_http_accept(login: account_attrs[:email], password: account_attrs[:password])
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'login disabled' do
    before do
      allow(configuration.web.login).to receive(:enabled) { false }
      Rails.application.reload_routes!
    end

    it 'returns 404' do
      post '/login', login: account_attrs[:email], password: account_attrs[:password]
      expect(response.status).to eq(404)
    end
  end

  describe 'login next_uri changed' do
    before { allow(configuration.web.login).to receive(:next_uri).and_return('/abc') }

    it 'should redirect to next_uri' do
      post '/login', login: account_attrs[:email], password: account_attrs[:password]
      expect(response).to redirect_to('/abc')
      expect(response.status).to eq(302)
    end
  end

  describe 'login sent with ?next=other_url' do
    it 'should redirect to next_uri' do
      post '/login?next=/other', login: account_attrs[:email], password: account_attrs[:password]
      expect(response).to redirect_to('/other')
      expect(response.status).to eq(302)
    end
  end
end
