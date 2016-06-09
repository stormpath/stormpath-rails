require 'spec_helper'
require 'net/http'
require 'uri'

describe 'ChangePassword GET', type: :request, vcr: true do
  context 'application/json' do
    def json_change_get(sptoken: nil)
      get '/change', { sptoken: sptoken }, 'HTTP_ACCEPT' => 'application/json'
    end

    def response_body
      JSON.parse(response.body)
    end

    context 'password reset enabled' do
      before do
        enable_change_password
        Rails.application.reload_routes!
      end

      describe 'without sptoken' do
        it 'return 400' do
          json_change_get
          expect(response.status).to eq(400)
          expect(response_body['message']).to eq('sptoken parameter not provided.')
        end
      end

      describe 'with incorrect sptoken' do
        it 'return 400' do
          json_change_get(sptoken: 'zzz')
          expect(response.status).to eq(400)
          expect(response_body['message']).to eq('sptoken parameter not provided.')
        end
      end

      describe 'with correct sptoken' do
        let(:account) { Stormpath::Rails::Client.application.accounts.create(account_attrs) }

        let(:account_attrs) do
          {
            email: 'example@test.com',
            given_name: 'Example',
            surname: 'Test',
            password: 'Pa$$W0RD',
            username: 'SirExample'
          }
        end

        let(:password_reset_token) do
          Stormpath::Rails::Client.application.password_reset_tokens.create(
            email: account.email
          ).token
        end

        after { account.delete }

        it 'returns 200' do
          json_change_get(sptoken: password_reset_token)
          expect(response.status).to eq(200)
        end
      end
    end

    context 'password reset disabled' do
      before do
        disable_change_password
        Rails.application.reload_routes!
      end

      it 'return 404' do
        json_change_get
        expect(response.status).to eq(404)
      end
    end
  end

  context 'text/html' do
    context 'password reset enabled' do
      before do
        enable_change_password
        Rails.application.reload_routes!
      end

      describe 'without sptoken' do
        it 'redirects to forgot password uri' do
          get '/change'
          expect(response).to redirect_to('/forgot')
        end
      end
    end

    context 'password reset disabled' do
      before do
        disable_change_password
        Rails.application.reload_routes!
      end

      it 'renders 404' do
        get '/change'
        expect(response.status).to eq(404)
      end
    end
  end
end
