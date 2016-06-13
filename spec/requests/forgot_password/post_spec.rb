require 'spec_helper'

describe 'ForgotPassword POST', type: :request, vcr: true do
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

  before do
    user
    enable_forgot_password
    Rails.application.reload_routes!
  end

  after { user.delete }

  context 'application/json' do
    def json_forgot_post(attrs)
      post '/forgot', attrs, 'HTTP_ACCEPT' => 'application/json'
    end

    context 'valid data' do
      it 'return 200 OK' do
        json_forgot_post(email: user.email)
        expect(response).to be_success
      end
    end

    context 'invalid data' do
      it 'return 200 OK' do
        json_forgot_post(email: 'test@testable.com')
        expect(response).to be_success
      end
    end
  end

  context 'text/html' do
    context 'valid data' do
      it 'redirects to login' do
        post '/forgot', email: user.email
        expect(response).to redirect_to('/login?status=forgot')
      end
    end

    context 'invalid data' do
      it 'with wrong email redirects to login' do
        post '/forgot', email: 'test@testable.com'
        expect(response).to redirect_to('/login?status=forgot')
      end

      it 'with no email redirects to login' do
        post '/forgot', email: ''
        expect(response).to redirect_to('/login?status=forgot')
      end
    end
  end
end
