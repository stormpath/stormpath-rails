require 'spec_helper'

describe 'Oauth2 POST', type: :request, vcr: true do
  let(:user) { Stormpath::Rails::Client.application.accounts.create(user_attrs) }

  let(:user_attrs) do
    {
      email: 'example@test.com',
      given_name: 'Example',
      surname: 'Test',
      password: 'Pa$$W0RD',
      username: 'SirExample'
    }
  end

  before { user }

  before do
    Rails.application.reload_routes!
  end

  after { user.delete }

  xdescribe 'HTTP_ACCEPT=text/html' do
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
    def json_oauth2_post(attrs = {})
      post '/oauth/token', attrs, 'HTTP_ACCEPT' => 'application/json'
    end

    xdescribe 'Client Credentials Grant Flow' do
      it 'successfull login should result with 200' do
        json_oauth2_post(login: user_attrs[:email], password: user_attrs[:password])
        expect(response.status).to eq(200)
      end

      it 'successfull login with username should result with 200' do
        json_oauth2_post(login: user_attrs[:username], password: user_attrs[:password])
        expect(response.status).to eq(200)
      end

      it 'successfull login should have content-type application/json' do
        json_oauth2_post(login: user_attrs[:email], password: user_attrs[:password])
        expect(response.content_type.to_s).to eq('application/json')
      end

      it 'successfull login should match schema' do
        json_oauth2_post(login: user_attrs[:email], password: user_attrs[:password])
        expect(response).to match_response_schema(:login_response, strict: true)
      end

      it 'successful login should match json' do
        json_oauth2_post(login: user_attrs[:email], password: user_attrs[:password])
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
        json_oauth2_post(login: user_attrs[:email], password: 'WR00N6')
        expect(response.status).to eq(400)
      end

      it 'failed login, wrong password should result with a message in the response body' do
        json_oauth2_post(login: user_attrs[:email], password: 'WR00N6')

        response_body = JSON.parse(response.body)
        expect(response_body['status']).to eq(400)
        expect(response_body['message']).to eq('Invalid username or password.')
      end
    end

    describe 'Password Grant Flow' do
      it 'should return success on valid request' do
        json_oauth2_post(
          grant_type: :password,
          username: user.email,
          password: user_attrs[:password]
        )

        expect(response).to match_json <<-JSON
        {
          "access_token":"{string}",
          "expires_in":3600,
          "refresh_token":"{string}",
          "token_type":"Bearer"
        }
        JSON
      end

      it 'should return 400 on invalid request' do
        json_oauth2_post(
          grant_type: :password,
          username: user.email,
          password: 'WRONG PASSWORD'
        )

        expect(response).to match_json <<-JSON
        {
          "error": "invalid_request",
          "message": "Invalid username or password."
        }
        JSON
      end
    end

    describe 'Refresh Grant Flow' do
      let(:refresh_token) do
        login_form = Stormpath::Rails::LoginForm.new(
          login: user.email,
          password: user_attrs[:password]
        )
        login_form.save!.refresh_token
      end

      it 'should return success on valid request' do
        json_oauth2_post(
          grant_type: :refresh_token,
          refresh_token: refresh_token
        )

        expect(response).to match_json <<-JSON
        {
          "access_token":"{string}",
          "expires_in":3600,
          "refresh_token":"{string}",
          "token_type":"Bearer"
        }
        JSON
      end

      it 'should return 400 on invalid request' do
        json_oauth2_post(
          grant_type: :refresh_token,
          refresh_token: 'INVALID TOKEN'
        )

        expect(response).to match_json <<-JSON
        {
          "error": "invalid_grant",
          "message": "Token is invalid"
        }
        JSON
      end
    end

    describe 'Unsupported value for grant type' do
      it 'should return 400' do
        json_oauth2_post(grant_type: 'passwordx')
        expect(response.status).to eq(400)
        expect(response).to match_json <<-JSON
        {
          "error": "unsupported_grant_type"
        }
        JSON
      end
    end

    describe 'nil for grant type' do
      it 'should return 400' do
        json_oauth2_post
        expect(response.status).to eq(400)
        expect(response).to match_json <<-JSON
        {
          "error": "invalid_request"
        }
        JSON
      end
    end

    describe 'empty string for grant type' do
      it 'should return 400' do
        json_oauth2_post(grant_type: '')
        expect(response.status).to eq(400)
        expect(response).to match_json <<-JSON
        {
          "error": "invalid_request"
        }
        JSON
      end
    end
  end
end
