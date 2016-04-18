require 'spec_helper'

describe 'Login', type: :request, vcr: true do
  describe 'POST /login' do
    let(:user) { Stormpath::Rails::Client.application.accounts.create(user_attrs) }

    let(:user_attrs) do
      { email: 'example@test.com', given_name: 'Example', surname: 'Test', password: 'Pa$$W0RD' }
    end

    before { user }

    before do
      Rails.application.reload_routes!
    end

    after  { user.delete }

    describe 'HTTP_ACCEPT=text/html' do
      describe 'html is enabled' do
        it 'successfull login' do
          post '/login', user_attrs.slice(:email, :password)
          expect(response).to redirect_to('/')
          expect(response.status).to eq(302)
        end

        it 'failed login, wrong password' do
          post '/login', user_attrs.slice(:email).merge(password: 'WR00N6')
          expect(response.status).to eq(200)
          expect(response.body).to include('Invalid username or password')
        end
      end

      describe 'html is disabled' do
        before do
          allow(Stormpath::Rails.config.produces).to receive(:accepts) { ['application/json'] }
          Rails.application.reload_routes!
        end

        it 'returns 404' do
          post '/login', user_attrs.slice(:email, :password)
          expect(response.status).to eq(404)
        end
      end
    end

    describe 'HTTP_ACCEPT=application/json' do
      def json_login_post(attrs)
        post '/login', attrs, { 'HTTP_ACCEPT' => 'application/json' }
      end

      describe 'json is enabled' do
        it 'successfull login' do
          json_login_post(user_attrs.slice(:email, :password))
          expect(response.status).to eq(200)
        end
        it 'failed login, wrong password' do
          json_login_post(user_attrs.slice(:email).merge(password: 'WR00N6'))
          expect(response.status).to eq(400)
        end
      end

      describe 'json is disabled' do
        before do
          allow(Stormpath::Rails.config.produces).to receive(:accepts) { ['application/html'] }
          Rails.application.reload_routes!
        end

        it 'returns 404' do
          json_login_post(user_attrs.slice(:email, :password))
          expect(response.status).to eq(404)
        end
      end
    end

    describe 'login disabled' do
      before do
        allow(Stormpath::Rails.config.login).to receive(:enabled) { false }
        Rails.application.reload_routes!
      end

      it 'returns 404' do
        post '/login', user_attrs.slice(:email, :password)
        expect(response.status).to eq(404)
      end
    end

    describe 'login next_uri changed' do
      before { Stormpath::Rails.config.login.next_uri = '/abc' }
      after  { Stormpath::Rails.config.login.reset_attributes }

      it 'should redirect to next_uri' do
        post '/login', user_attrs.slice(:email, :password)
        expect(response).to redirect_to('/abc')
        expect(response.status).to eq(302)
      end
    end
  end

  describe 'GET /login' do

  end
end
