require 'spec_helper'

describe 'ForgotPassword POST', type: :request, vcr: true do
  let(:account) { Stormpath::Rails::Client.application.accounts.create(account_attrs) }

  let(:account_attrs) { FactoryGirl.attributes_for(:account) }

  before do
    account
    enable_forgot_password
    Rails.application.reload_routes!
  end

  after { account.delete }

  context 'application/json' do
    def json_forgot_post(attrs = {})
      post '/forgot', attrs, 'HTTP_ACCEPT' => 'application/json'
    end

    context 'valid data' do
      it 'return 200 OK' do
        json_forgot_post(email: account.email)
        expect(response).to be_success
      end
    end

    context 'invalid data' do
      it 'return 200 OK' do
        json_forgot_post(email: 'test@testable.com')
        expect(response).to be_success
      end

      context 'no email' do
        it 'return 404' do
          json_forgot_post
          expect(response.status).to eq(400)
        end
      end
    end
  end
end
