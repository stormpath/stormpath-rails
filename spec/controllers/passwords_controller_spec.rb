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
end