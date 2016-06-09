require 'spec_helper'

describe 'Login POST', type: :request, vcr: true do
  let(:user) { Stormpath::Rails::Client.application.accounts.create(user_attrs) }

  let(:user_attrs) do
    { email: 'example@test.com', given_name: 'Example', surname: 'Test', password: 'Pa$$W0RD', username: 'SirExample' }
  end

  before { user }

  before do
    Rails.application.reload_routes!
  end

  after  { user.delete }

  describe 'HTTP_ACCEPT=text/html' do
    describe 'html is enabled' do
      it 'successfull login' do
        post '/login', login: user_attrs[:email], password: user_attrs[:password]
        expect(response).to redirect_to('/')
        expect(response.status).to eq(302)
      end

      it 'failed login, wrong password' do
        post '/login', login: user_attrs[:email], password: 'WR00N6'
        expect(response.status).to eq(200)
        expect(response.body).to include('Invalid username or password')
      end
    end

    describe 'html is disabled' do
      before do
        allow(Stormpath::Rails.config.web).to receive(:produces) { ['application/json'] }
        Rails.application.reload_routes!
      end

      it 'returns 404' do
        post '/login', login: user_attrs[:email], password: user_attrs[:password]
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'HTTP_ACCEPT=application/json' do
    def json_login_post(attrs)
      post '/login', attrs, { 'HTTP_ACCEPT' => 'application/json' }
    end

    describe 'json is enabled' do
      it 'successfull login should result with 200' do
        json_login_post(login: user_attrs[:email], password: user_attrs[:password])
        expect(response.status).to eq(200)
      end

      it 'successfull login with username should result with 200' do
        json_login_post(login: user_attrs[:username], password: user_attrs[:password])
        expect(response.status).to eq(200)
      end

      it 'successfull login should have content-type application/json' do
        json_login_post(login: user_attrs[:email], password: user_attrs[:password])
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'successfull login should match schema' do
        json_login_post(login: user_attrs[:email], password: user_attrs[:password])
        expect(response).to match_response_schema(:login_response, strict: true)
      end

      it 'successful login should match json' do
        json_login_post(login: user_attrs[:email], password: user_attrs[:password])
        expect(response).to match_json <<-JSON
        {
           "account":{
              "href":"{string}",
              "username":"SirExample",
              "modifiedAt":"{date_time_iso8601}",
              "status":"ENABLED",
              "createdAt":"{date_time_iso8601}",
              "email":"example@test.com",
              "middleName":null,
              "surname":"Test",
              "givenName":"Example",
              "fullName":"Example Test"
           }
        }
        JSON
      end

      it 'failed login, wrong password should result with 400' do
        json_login_post(login: user_attrs[:email], password: 'WR00N6')
        expect(response.status).to eq(400)
      end

      it 'failed login, wrong password should result with only a message and a status in the response body' do
        json_login_post(login: user_attrs[:email], password: 'WR00N6')

        response_body = JSON.parse(response.body)
        expect(response_body['status']).to eq(400)
        expect(response_body['message']).to eq('Invalid username or password.')
      end
    end

    describe 'json is disabled' do
      before do
        allow(Stormpath::Rails.config.web).to receive(:produces) { ['application/html'] }
        Rails.application.reload_routes!
      end

      it 'returns 404' do
        json_login_post(login: user_attrs[:email], password: user_attrs[:password])
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'HTTP_ACCEPT=nil' do
    def login_post_with_nil_http_accept(attrs)
      post '/login', attrs, { 'HTTP_ACCEPT' => nil }
    end

    describe 'json is enabled' do
      it 'successfull login should result with 200' do
        login_post_with_nil_http_accept(login: user_attrs[:email], password: user_attrs[:password])
        expect(response.status).to eq(200)
      end

      it 'successfull login with username should result with 200' do
        login_post_with_nil_http_accept(login: user_attrs[:username], password: user_attrs[:password])
        expect(response.status).to eq(200)
      end

      it 'successfull login should have content-type application/json' do
        login_post_with_nil_http_accept(login: user_attrs[:email], password: user_attrs[:password])
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'successfull login should match schema' do
        login_post_with_nil_http_accept(login: user_attrs[:email], password: user_attrs[:password])
        expect(response).to match_response_schema(:login_response, strict: true)
      end

      it 'failed login, wrong password should result with 400' do
        login_post_with_nil_http_accept(login: user_attrs[:email], password: 'WR00N6')
        expect(response.status).to eq(400)
      end

      it 'failed login, wrong password should result with only a message and a status in the response body' do
        login_post_with_nil_http_accept(login: user_attrs[:email], password: 'WR00N6')

        response_body = JSON.parse(response.body)
        expect(response_body['status']).to eq(400)
        expect(response_body['message']).to eq('Invalid username or password.')
      end
    end

    describe 'json is disabled' do
      before do
        allow(Stormpath::Rails.config.web).to receive(:produces) { ['text/html'] }
        Rails.application.reload_routes!
      end

      it 'returns 404' do
        login_post_with_nil_http_accept(login: user_attrs[:email], password: user_attrs[:password])
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'login disabled' do
    before do
      allow(Stormpath::Rails.config.web.login).to receive(:enabled) { false }
      Rails.application.reload_routes!
    end

    it 'returns 404' do
      post '/login', login: user_attrs[:email], password: user_attrs[:password]
      expect(response.status).to eq(404)
    end
  end

  describe 'login next_uri changed' do
    before { allow(Stormpath::Rails.config.web.login).to receive(:next_uri).and_return('/abc') }

    it 'should redirect to next_uri' do
      post '/login', login: user_attrs[:email], password: user_attrs[:password]
      expect(response).to redirect_to('/abc')
      expect(response.status).to eq(302)
    end
  end

  describe 'login sent with ?next=other_url' do
    it 'should redirect to next_uri' do
      post '/login?next=other', login: user_attrs[:email], password: user_attrs[:password]
      expect(response).to redirect_to('/other')
      expect(response.status).to eq(302)
    end
  end
end
