require 'spec_helper'

describe Stormpath::Rails::PasswordsController, type: :controller do
  it { should be_a Stormpath::Rails::BaseController }

  describe "GET #forgot" do
    context "password reset enabled" do
      before do
        Stormpath::Rails.config.enable_forgot_password = true
      end

      it "renders forgot password view" do
        get :forgot

        expect(response).to be_success
        expect(response).to render_template(:forgot)
      end
    end

    context "password reset disabled" do
      before do
        Stormpath::Rails.config.enable_forgot_password = false
      end

      it "redirects to root_path" do
        get :forgot

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST #forgot_send" do
    before do
      create_test_account
      Stormpath::Rails.config.enable_forgot_password = true
    end

    context "valid data" do
      it "renders email sent view" do
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
    end
  end
end