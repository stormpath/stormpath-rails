require 'spec_helper'

describe 'ForgotPassword GET', type: :request, vcr: true do
  context 'application/json' do
    def json_forgot_get
      get '/forgot', {}, 'HTTP_ACCEPT' => 'application/json'
    end

    context 'password reset enabled' do
      before do
        enable_forgot_password
        Rails.application.reload_routes!
      end

      it 'return 404' do
        json_forgot_get
        expect(response.status).to eq(404)
      end
    end

    context 'password reset disabled' do
      before do
        disable_forgot_password
        Rails.application.reload_routes!
      end

      it 'return 404' do
        json_forgot_get
        expect(response.status).to eq(404)
      end
    end
  end

  context 'text/html' do
    context 'password reset enabled' do
      before do
        enable_forgot_password
        Rails.application.reload_routes!
      end

      it 'return 200' do
        get '/forgot'
        expect(response.status).to eq(200)
      end

      describe 'if id site is enabled' do
        before do
          allow(web_config.id_site).to receive(:enabled).and_return(true)
          Rails.application.reload_routes!
        end

        after do
          allow(web_config.id_site).to receive(:enabled).and_return(false)
          Rails.application.reload_routes!
        end

        it 'should respond with 302' do
          get '/forgot'
          expect(response.status).to eq(302)
        end

        it 'should redirect to id site' do
          get '/forgot'
          expect(response.headers['Location']).to include('https://api.stormpath.com/sso')
        end
      end
    end

    context 'password reset disabled' do
      before do
        disable_forgot_password
        Rails.application.reload_routes!
      end

      it 'renders 404' do
        get '/forgot'
        expect(response.status).to eq(404)
      end
    end
  end
end
