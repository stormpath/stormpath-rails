require 'spec_helper'

describe Stormpath::Rails::PasswordsController, :vcr, type: :controller do
  it { should be_a Stormpath::Rails::BaseController }

  describe "GET #forgot" do
    context "password reset enabled" do
      before do
        enable_forgot_password
      end

      it "renders forgot password view" do
        get :forgot

        expect(response).to be_success
        expect(response).to render_template(:forgot)
      end
    end

    context "password reset disabled" do
      before do
        disable_forgot_password
      end

      it "redirects to root_path" do
        get :forgot

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST #forgot_send" do
    let(:account_success) { double(Stormpath::Rails::AccountStatus, success?: true, account_url: 'xyz') }

    before do
      create_test_account
      enable_forgot_password
    end

    after do
      delete_test_account
    end

    context "application/json request" do
      before { request.headers['HTTP_ACCEPT'] = 'application/json' }

      context "valid data" do
        it "returnes success" do
          allow(controller).to receive(:reset_password).and_return(account_success)
          post :forgot_send, format: :json, password: { email: test_user.email }

          expect(response).to be_success
          expect(response.body).to be_empty
        end
      end

      context "invalid data" do
        it "returne errors" do
          post :forgot_send, format: :json, password: { email: "test@testable.com" }
          response_body = JSON.parse(response.body)
          expect(response_body["error"]).to eq("The email property value 'test@testable.com' does not match a known resource.")
        end

        it "returnes 400" do
          post :forgot_send, format: :json, password: { email: "test@testable.com" }
          expect(response.status).to eq(400)
        end
      end
    end

    context "valid data" do
      it "renders email sent view" do
        allow(controller).to receive(:reset_password).and_return(account_success)
        post :forgot_send, password: { email: test_user.email }

        expect(response).to be_success
        expect(response).to render_template(:email_sent)
      end
    end

    context "invalid data" do
      it "renders email sent view" do
        post :forgot_send, password: { email: "test@testable.com" }
        expect(response).to render_template(:forgot)
      end

      it "shows error message" do
        post :forgot_send, password: { email: "test@testable.com" }
        expect(flash[:error]).to eq('Invalid email address.')
      end

      it "shows error message" do
        post :forgot_send, password: { email: "" }
        expect(flash[:error]).to eq('Invalid email address.')
      end
    end
  end

  describe "GET #forgot_change" do
    let(:account_success) { double(Stormpath::Rails::AccountStatus, success?: true, account_url: 'xyz') }
    let(:account_failed) { double(Stormpath::Rails::AccountStatus, success?: false, account_url: 'xyz') }

    context "valid token" do
      it "renders form for password change" do
        allow(controller).to receive(:verify_email_token).and_return(account_success)
        get :forgot_change

        expect(response).to be_success
        expect(response).to render_template(:forgot_change)
      end
    end

    context "invalid token" do
      it "renders form for password change" do
        allow(controller).to receive(:verify_email_token).and_return(account_failed)
        get :forgot_change

        expect(response).to be_success
        expect(response).to render_template(:forgot_change_failed)
      end
    end
  end

  describe "POST #change_password" do
    let(:test_account) { create_test_account }
    let(:valid_passwords)     { { password: { original: 'Somepass123', repeated: 'Somepass123' } } }
    let(:different_passwords) { { password: { original: 'Somepass123', repeated: 'Somepass' } } }
    let(:invalid_passwords)   { { password: { original: 'invalid', repeated: 'invalid' } } }
    let(:account_success) { double(Stormpath::Rails::AccountStatus, success?: true, account_url: 'xyz') }

    after do
      delete_test_account
    end

    context "valid passwords" do
      it "something" do
        allow(controller).to receive(:update_password).and_return(account_success)
        post :forgot_update, valid_passwords.merge(account_url: test_account.account_url)

        expect(response).to be_success
        expect(response).to render_template(:forgot_complete)
      end
    end

    context "invalid passwords" do
      it "renders change form with do not match error" do
        post :forgot_update, different_passwords.merge(account_url: test_account.account_url)

        expect(response).to render_template(:forgot_change)
        expect(flash[:error]).to eq('Passwords do not match.')
      end

      it "renders change form with response errors" do
        post :forgot_update, invalid_passwords.merge(account_url: test_account.account_url)

        expect(response).to render_template(:forgot_change)
        expect(flash[:error]).to_not be_empty
      end
    end
  end
end
