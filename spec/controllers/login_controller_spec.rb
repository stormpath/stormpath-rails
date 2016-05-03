require "spec_helper"

describe Stormpath::Rails::LoginController, :vcr, type: :controller do
  it { should be_a Stormpath::Rails::BaseController }

  describe "GET #new" do
    before { request.headers['HTTP_ACCEPT'] = 'text/html' }

    context "user not signed in" do
      it "renders new template" do
        get :new

        expect(response).to be_success
        expect(response).to render_template(:new)
      end
    end

    context "user signed in" do
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
          .with({ callback_uri: @controller.request.base_url + "/redirect" })
          .and_return(root_path)

        get :new
      end
    end

    context "login not enabled" do
      before do
        Stormpath::Rails.config.login = { enabled: false, next_uri: "/" }
      end

      after { Stormpath::Rails.config.login.reset_attributes }

      it "redirects to next_uri" do
        sign_in
        get :new

        expect(response).to redirect_to(Stormpath::Rails.config.login.next_uri)
      end
    end
  end

  describe "GET #redirect" do
    let(:account) do
      user = create(:user)
      allow(user).to receive(:href).and_return('/tets_account_href')
      user
    end

    it "redirects to id_site next_uri" do
      allow(controller).to receive(:handle_id_site_callback).and_return(account)
      get :redirect

      expect(response).to redirect_to(root_path)
    end

    context "custom next_uri" do
      before do
        Stormpath::Rails.config.id_site.next_uri = '/custom'
      end

      after { Stormpath::Rails.config.login.reset_attributes }

      it "redirects to next_uri" do
        allow(controller).to receive(:handle_id_site_callback).and_return(account)
        get :redirect

        expect(response).to redirect_to('/custom')
      end
    end
  end

  describe "POST #create" do
    before do
      create_test_account
    end

    after do
      delete_test_account
    end

    context "application/json request" do
      before { request.headers['HTTP_ACCEPT'] = 'application/json' }

      context "valid parameters" do
        it "signs in user" do
          post :create, login: test_user.email, password: test_user.password

          response_body = JSON.parse(response.body)
          expect(response_body["account"]["email"]).to eq(test_user.email)
          expect(response_body["account"]["givenName"]).to eq(test_user.given_name)
          expect(response_body["account"]["surname"]).to eq(test_user.surname)
        end
      end

      context "invalid parameters" do
        it "reuterns list of errors" do
          post :create, login: "test@testable.com", password: test_user.password

          response_body = JSON.parse(response.body)
          expect(response_body["message"]).to eq("Invalid username or password.")
        end
      end
    end

    context "valid parameters" do
      before { request.headers['HTTP_ACCEPT'] = 'text/html' }

      it "signs in user" do
        post :create, login: test_user.email, password: test_user.password

        expect(response).to redirect_to(root_path)
        expect(response.cookies['access_token']).to be
        expect(response.cookies['refresh_token']).to be
        expect(flash[:notice]).to eq("Successfully signed in")
      end
    end

    context "invalid parameters" do
      before { request.headers['HTTP_ACCEPT'] = 'text/html' }

      it "renders new template with errors" do
        post :create, login: "test@testable.com", password: test_user.password

        expect(response).to be_success
        expect(response).to render_template(:new)
        expect(flash[:error]).to eq("Invalid username or password.")
      end
    end

    context "custom next_uri" do
      before do
        Stormpath::Rails.config.login.next_uri = '/custom'
      end

      before { request.headers['HTTP_ACCEPT'] = 'text/html' }
      after { Stormpath::Rails.config.login.reset_attributes }

      it "redirects to next_uri" do
        post :create, login: test_user.email, password: test_user.password
        expect(response).to redirect_to('/custom')
      end
    end
  end
end
