require 'spec_helper'

describe Stormpath::Rails::ForgotPasswordsController, :vcr, type: :controller do
  it { should be_a Stormpath::Rails::BaseController }

  describe "GET #forgot" do
    context "password reset enabled" do
      before do
        enable_forgot_password
        Rails.application.reload_routes!
      end

      it "renders forgot password view" do
        get :new

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
        get :new
        expect(response.status).to eq(404)
      end
    end
  end

  describe "POST #forgot_send" do
    let(:account_success) { double(Stormpath::Rails::AccountStatus, success?: true, account_url: 'xyz') }

    before do
      create_test_account
      enable_forgot_password
      Rails.application.reload_routes!
    end

    after do
      delete_test_account
    end

    context "application/json request" do
      before { request.headers['HTTP_ACCEPT'] = 'application/json' }

      context "valid data" do
        it "redirects further" do
          allow(controller).to receive(:reset_password).and_return(account_success)
          post :create, format: :json, password: { email: test_user.email }
          expect(response).to be_success
        end
      end

      context "invalid data" do
        it "return 200 OK" do
          post :create, format: :json, password: { email: "test@testable.com" }
          expect(response).to be_success
        end

        it "returnes 400" do
          post :create, format: :json, password: { email: "test@testable.com" }
          expect(response).to be_success
        end
      end
    end

    context "valid data" do
      it "renders email sent view" do
        allow(controller).to receive(:reset_password).and_return(account_success)
        post :create, password: { email: test_user.email }
        expect(response).to redirect_to('/login?status=forgot')
      end
    end

    context "invalid data" do
      it "with wrong email redirects" do
        post :create, password: { email: "test@testable.com" }
        expect(response).to redirect_to('/login?status=forgot')
      end

      it "with no email redirects" do
        post :create, password: { email: "" }
        expect(response).to redirect_to('/login?status=forgot')
      end
    end
  end

end
