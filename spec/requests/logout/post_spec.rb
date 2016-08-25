require 'spec_helper'

describe 'Logout POST', type: :request, vcr: true do
  let(:account) { Stormpath::Rails::Client.application.accounts.create(account_attrs) }

  let(:account_attrs) { FactoryGirl.attributes_for(:account) }

  before do
    Rails.application.reload_routes!
  end

  after { account.delete }

  describe 'with cookies' do
    before do
      post '/login', login: account.email, password: account_attrs[:password]
    end

    describe 'HTTP_ACCEPT=text/html' do
      describe 'html is enabled' do
        it 'successfull logout' do
          post '/logout'
          expect(response).to redirect_to('/')
          expect(response.status).to eq(302)
        end
      end

      describe 'html is disabled' do
        before do
          allow(configuration.web).to receive(:produces) { ['application/json'] }
          Rails.application.reload_routes!
        end

        it 'returns 404' do
          post '/logout'
          expect(response.status).to eq(404)
        end
      end
    end

    describe 'HTTP_ACCEPT=application/json' do
      def json_logout_post
        post '/logout', nil, 'HTTP_ACCEPT' => 'application/json'
      end

      describe 'json is enabled' do
        it 'successfull logout should result with 200' do
          expect(account.access_tokens.count).to eq(1)
          expect(account.refresh_tokens.count).to eq(1)
          json_logout_post
          expect(response.status).to eq(200)
          expect(response.body).to be_blank
          expect(account.access_tokens.count).to eq(0)
          expect(account.refresh_tokens.count).to eq(0)
        end
      end

      describe 'json is disabled' do
        before do
          allow(configuration.web).to receive(:produces) { ['text/html'] }
          Rails.application.reload_routes!
        end

        it 'returns 404' do
          json_logout_post
          expect(response.status).to eq(404)
        end
      end
    end

    describe 'logout disabled' do
      before do
        allow(configuration.web.logout).to receive(:enabled) { false }
        Rails.application.reload_routes!
      end

      it 'returns 404' do
        post '/logout'
        expect(response.status).to eq(404)
      end
    end

    describe 'logout next_uri changed' do
      before { allow(configuration.web.logout).to receive(:next_uri).and_return('/abc') }

      it 'should redirect to next_uri' do
        post '/logout'
        expect(response).to redirect_to('/abc')
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'with bearer token' do
    describe 'HTTP_ACCEPT=application/json' do
      def json_logout_post
        post(
          '/logout',
          {},
          'HTTP_ACCEPT' => 'application/json',
          'HTTP_AUTHORIZATION' => "Bearer #{access_token}"
        )
      end

      describe 'json is enabled' do
        let(:access_token) do
          login_form = Stormpath::Rails::LoginForm.new(account.email, account_attrs[:password])
          login_form.save!
          login_form.authentication_result.access_token
        end

        it 'successfull logout should result with 200' do
          access_token
          expect(account.access_tokens.count).to eq(1)
          expect(account.refresh_tokens.count).to eq(1)
          json_logout_post
          expect(response.status).to eq(200)
          expect(response.body).to be_blank
          expect(account.access_tokens.count).to eq(0)
          expect(account.refresh_tokens.count).to eq(1)
        end
      end

      describe 'fake access_token' do
        let(:access_token) { 'dsdasdasdasdsa' }

        it 'successfull logout should result with 200' do
          access_token
          json_logout_post
          expect(response.status).to eq(200)
          expect(response.body).to be_blank
        end
      end
    end
  end
end
