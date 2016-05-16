require 'spec_helper'

describe Stormpath::Rails::ChangePasswordsController, :vcr, type: :controller do
  it { should be_a Stormpath::Rails::BaseController }

  describe "GET #forgot_change" do
    let(:account_success) { double(Stormpath::Rails::AccountStatus, success?: true, account_url: 'xyz') }
    let(:account_failed) { double(Stormpath::Rails::AccountStatus, success?: false, account_url: 'xyz') }

    context "valid token" do
      it "renders form for password change" do
        allow(controller).to receive(:verify_email_token).and_return(account_success)
        get :new, sptoken: 'something'

        expect(response).to be_success
        expect(response).to render_template(:forgot_change)
      end
    end

    context "invalid token" do
      it "renders form for password change" do
        allow(controller).to receive(:verify_email_token).and_return(account_failed)
        get :new, sptoken: 'something'

        expect(response).to redirect_to('/forgot?status=invalid_sptoken')
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
        post :create, valid_passwords.merge(account_url: test_account.account_url)

        expect(response).to be_success
        expect(response).to render_template(:forgot_complete)
      end
    end

    context "invalid passwords" do
      it "renders change form with do not match error" do
        post :create, different_passwords.merge(account_url: test_account.account_url)

        expect(response).to render_template(:forgot_change)
        expect(flash[:error]).to eq('Passwords do not match.')
      end

      it "renders change form with response errors" do
        post :create, invalid_passwords.merge(account_url: test_account.account_url)

        expect(response).to render_template(:forgot_change)
        expect(flash[:error]).to_not be_empty
      end
    end
  end
end
