require "spec_helper"

describe Stormpath::Rails::UsersController, type: :controller do
  it { should be_a Stormpath::Rails::BaseController }

  before do
    Stormpath::Rails.config.id_site = { enabled: false }
  end

  describe "GET #new" do
    context "when signed out" do
      it "renders a form for a new user" do
        get :new

        expect(response).to be_success
        expect(response).to render_template(:new)
      end
    end

    context "when not signed in" do
      it "redirects to root_path" do
        sign_in
        get :new

        expect(response).to redirect_to(root_path)
      end
    end

    context "id site enabled" do
      before do
        Stormpath::Rails.config.id_site = { enabled: true, uri: "/redirect" }
      end

      it "calls id_site_url on client with correct options" do
        expect(Stormpath::Rails::Client).to receive(:id_site_url)
          .with({callback_uri: @controller.request.base_url + "/redirect", path: "/#register" })
          .and_return(root_path)

        get :new
      end
    end
  end

  describe "GET #verify" do
    let(:account_success) { double(Stormpath::Rails::AccountStatus, success?: true, account_url: 'xyz') }
    let(:account_failed) { double(Stormpath::Rails::AccountStatus, success?: false, account_url: 'xyz') }

    context "valid sptoken" do
      it "renders success verification view" do
        allow(controller).to receive(:verify_email_token).and_return(account_success)
        get :verify

        expect(response).to be_success
        expect(response).to render_template(:verification_complete)
      end
    end

    context "invalid sptoken" do
      it "renders failed verification view" do
        allow(controller).to receive(:verify_email_token).and_return(account_failed)
        get :verify

        expect(response).to be_success
        expect(response).to render_template(:verification_failed)
      end
    end
  end

  describe "POST #create" do
    let(:user_attributes) { attributes_for(:user) }

    context "invalid data" do
      it "without email render email error" do
        post :create, user: attributes_for(:user, email: "")
        expect(flash[:error]).to eq('Account email address cannot be null, empty, or blank.')
      end

      it "with invalid email render email error" do
        post :create, user: attributes_for(:user, email: "test")
        expect(flash[:error]).to eq('Account email address is in an invalid format.')
      end

      it "without password render password error" do
        post :create, user: attributes_for(:user, password: "")
        expect(flash[:error]).to eq('Account data cannot be null, empty, or blank.')
      end

      it "with short password render password error" do
        post :create, user: attributes_for(:user, password: "pass")
        expect(flash[:error]).to eq('Account password minimum length not satisfied.')
      end

      it "without numeric character in password render numeric error" do
        post :create, user: attributes_for(:user, password: "somerandompass")
        expect(flash[:error]).to eq('Password requires at least 1 numeric character.')
      end

      it "without upercase character in password render upercase error" do
        post :create, user: attributes_for(:user, password: "somerandompass123")
        expect(flash[:error]).to eq('Password requires at least 1 uppercase character.')
      end
    end

    context "user verification enabled" do
      before do
        Stormpath::Rails.config.verify_email = true
      end

      it "creates a user" do
        expect { post :create, user: user_attributes }.to change(User, :count).by(1)
      end

      it "renders verified template" do
        post :create, user: user_attributes

        expect(response).to be_success
        expect(response).to render_template(:verification_email_sent)
      end
    end

    context "user verification disabled" do
      before do
        Stormpath::Rails.config.verify_email = false
      end

      it "creates a user" do
        expect { post :create, user: user_attributes }.to change(User, :count).by(1)
      end

      it "redirects to root_path on successfull login" do
        post :create, user: user_attributes
        expect(response).to redirect_to(root_path)
      end

      it "stores user_id in session" do
        post :create, user: user_attributes
        expect(session[:user_id]).to_not be_nil
      end
    end
  end
end