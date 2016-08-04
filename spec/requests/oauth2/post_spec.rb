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

  describe 'HTTP_ACCEPT=application/json' do
    def json_oauth2_post(attrs = {})
      post '/oauth/token', attrs, 'HTTP_ACCEPT' => 'application/json'
    end

    describe 'Client Credentials Grant Flow' do
      let(:api_key) { user.api_keys.create({}) }
      let(:api_key_id) { api_key.id }
      let(:api_key_secret) { api_key.secret }

      let(:encoded_auth_header) do
        Base64.encode64("#{api_key_id}:#{api_key_secret}")
      end

      def json_oauth2_post(headers = {})
        post(
          '/oauth/token',
          { grant_type: :client_credentials },
          { 'HTTP_ACCEPT' => 'application/json' }.merge(headers)
        )
      end

      it 'should return success on valid request' do
        json_oauth2_post(
          'HTTP_AUTHORIZATION' => "Basic #{encoded_auth_header}"
        )
        expect(response.status).to eq(200)
        expect(response).to match_json <<-JSON
        {
          "access_token":"{string}",
          "expires_in":3600,
          "token_type":"Bearer"
        }
        JSON
      end

      it 'should return valid response headers' do
        json_oauth2_post(
          'HTTP_AUTHORIZATION' => "Basic #{encoded_auth_header}"
        )
        expect(response.headers['Cache-Control']).to eq('no-store')
        expect(response.headers['Pragma']).to eq('no-cache')
      end

      describe 'missing api key secret' do
        let(:encoded_auth_header) do
          Base64.encode64("#{api_key_id}:")
        end

        it 'should return 401' do
          json_oauth2_post(
            'HTTP_AUTHORIZATION' => "Basic #{encoded_auth_header}"
          )
          expect(response.status).to eq(401)
          expect(response).to match_json <<-JSON
          {
            "error": "invalid_client",
            "message": "Api key secret can't be blank"
          }
          JSON
        end
      end

      describe 'wrong api key secret' do
        let(:encoded_auth_header) do
          Base64.encode64("#{api_key_id}:NOT_A_VALID_API_SECRET")
        end

        it 'should return 401' do
          json_oauth2_post(
            'HTTP_AUTHORIZATION' => "Basic #{encoded_auth_header}"
          )
          expect(response.status).to eq(401)
          expect(response).to match_json <<-JSON
          {
            "error": "invalid_client",
            "message": "API Key Authentication failed."
          }
          JSON
        end
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

      describe 'when password grant flow is disabled' do
        before do
          allow(web_config.oauth2.password).to receive(:enabled).and_return(false)
        end

        it 'should return 400 and error with unsupported_grant_type' do
          json_oauth2_post(
            grant_type: :password,
            username: user.email,
            password: 'WRONG PASSWORD'
          )

          expect(response).to match_json <<-JSON
          {
            "error": "unsupported_grant_type"
          }
          JSON
        end
      end
    end

    describe 'Refresh Grant Flow' do
      let(:refresh_token) do
        login_form = Stormpath::Rails::LoginForm.new(
          user.email,
          user_attrs[:password]
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

      it 'should return 400 on missing refresh token' do
        json_oauth2_post(
          grant_type: :refresh_token
        )

        expect(response).to match_json <<-JSON
        {
          "error": "invalid_grant",
          "message": "Refresh token can't be blank"
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

    describe 'when password grant flow is disabled' do
      before do
        allow(web_config.oauth2.password).to receive(:enabled).and_return(false)
      end

      it 'should return 400 and error with unsupported_grant_type' do
        json_oauth2_post(
          grant_type: :password,
          username: user.email,
          password: 'WRONG PASSWORD'
        )

        expect(response).to match_json <<-JSON
        {
          "error": "unsupported_grant_type"
        }
        JSON
      end
    end
  end
end
