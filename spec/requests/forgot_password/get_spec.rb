require 'spec_helper'

describe 'ForgotPassword GET', type: :request, vcr: true do
  context 'application/json' do
    def json_forgot_get
      get '/forgot', {}, { 'HTTP_ACCEPT' => 'application/json' }
    end

    context "password reset enabled" do
      before do
        enable_forgot_password
        Rails.application.reload_routes!
      end

      it "return 404" do
        json_forgot_get
        expect(response.status).to eq(404)
      end
    end

    context "password reset disabled" do
      before do
        disable_forgot_password
        Rails.application.reload_routes!
      end

      it "return 404" do
        json_forgot_get
        expect(response.status).to eq(404)
      end
    end
  end

  context 'text/html' do
    context "password reset enabled" do
      before do
        enable_forgot_password
        Rails.application.reload_routes!
      end

      it "renders forgot password view" do
        get '/forgot'
        expect(response).to be_success
        expect(response).to render_template(:forgot)
      end
    end

    context "password reset disabled" do
      before do
        disable_forgot_password
        Rails.application.reload_routes!
      end

      it "renders 404" do
        get '/forgot'
        expect(response.status).to eq(404)
      end
    end
  end
end
