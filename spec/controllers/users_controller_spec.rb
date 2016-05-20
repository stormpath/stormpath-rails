require "spec_helper"

describe Stormpath::Rails::UsersController, :vcr, type: :controller do
  it { should be_a Stormpath::Rails::BaseController }

  before do
    disable_id_site
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

    xcontext "id site enabled" do
      before do
        enable_id_site
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

  describe "GET #profile" do
    context "application/json request" do
      context "user signed in" do
        before do
          sign_in
        end

        it "returnes user profile data" do
          post :profile, format: :json
          response_body = JSON.parse(response.body)

          expect(response_body["email"]).to eq(test_user.email)
          expect(response_body["givenName"]).to eq(test_user.given_name)
          expect(response_body["surname"]).to eq(test_user.surname)
        end
      end

      context "user not signed in" do
        it "returnes 401" do
          post :profile, format: :json
          expect(response.status).to eq(401)
        end
      end
    end
  end

  describe "POST #create" do
    let(:user_attributes) { attributes_for(:user) }

    let(:camelized_user_attributes) do
      user_attributes.transform_keys { |key| key.to_s.camelize(:lower).to_sym }
    end

    context "application/json request" do
      before do
        request.accept = "application/json"
      end

      context "invalid data" do
        it "without email render email error" do
          post :create, camelized_user_attributes.merge(email: '')
          response_body = JSON.parse(response.body)

          expect(response_body["error"]).to eq('Account email address cannot be null, empty, or blank.')
        end
      end

      context "user verification enabled" do
        before do
          enable_verify_email
        end

        after { delete_account(user_attributes[:email]) }

        it "creates a user" do
          expect { post :create, camelized_user_attributes }.to change(User, :count).by(1)
        end

        it "returnes user data as response" do
          post :create, camelized_user_attributes
          response_body = JSON.parse(response.body)
          expect(response_body["account"]["email"]).to eq(user_attributes[:email])
          expect(response_body["account"]["givenName"]).to eq(user_attributes[:given_name])
          expect(response_body["account"]["surname"]).to eq(user_attributes[:surname])
        end
      end
    end

    context "invalid data" do
      it "without email render email error" do
        post :create, camelized_user_attributes.merge(email: "")
        expect(flash[:error]).to eq('Account email address cannot be null, empty, or blank.')
      end

      it "with invalid email render email error" do
        post :create, camelized_user_attributes.merge(email: "test")
        expect(flash[:error]).to eq('Account email address is in an invalid format.')
      end

      it "without password render password error" do
        post :create, camelized_user_attributes.merge(password: "")
        expect(flash[:error]).to eq('Account password minimum length not satisfied.')
      end

      it "with short password render password error" do
        post :create, camelized_user_attributes.merge(password: "pass")
        expect(flash[:error]).to eq('Account password minimum length not satisfied.')
      end

      it "without numeric character in password render numeric error" do
        post :create, camelized_user_attributes.merge(password: "somerandompass")
        expect(flash[:error]).to eq('Password requires at least 1 numeric character.')
      end

      it "without upercase character in password render upercase error" do
        post :create, camelized_user_attributes.merge(password: "somerandompass123")
        expect(flash[:error]).to eq('Password requires at least 1 uppercase character.')
      end
    end

    context "user verification enabled" do
      before do
        enable_verify_email
      end

      after { delete_account(user_attributes[:email]) }

      it "creates a user" do
        expect { post :create, camelized_user_attributes }.to change(User, :count).by(1)
      end

      it "renders verified template" do
        post :create, camelized_user_attributes

        expect(response).to be_success
        expect(response).to render_template(:verification_email_sent)
      end
    end

    context "user verification disabled" do
      before do
        disable_verify_email
      end

      after { delete_account(user_attributes[:email]) }

      it "creates a user" do
        expect { post :create,camelized_user_attributes }.to change(User, :count).by(1)
      end

      it "redirects to root_path on successfull login" do
        post :create, camelized_user_attributes
        expect(response).to redirect_to(root_path)
      end

      it "stores user_id in session" do
        post :create, camelized_user_attributes
        expect(session[:user_id]).to_not be_nil
      end
    end

    context "custom next_uri" do
      before do
        disable_verify_email
        Stormpath::Rails.config.web.register.next_uri = '/custom'
      end

      after { delete_account(user_attributes[:email]) }

      it "redirects to next_uri" do
        post :create, camelized_user_attributes
        expect(response).to redirect_to('/custom')
      end
    end
  end
end
