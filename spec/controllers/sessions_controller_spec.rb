require "spec_helper"

describe Stormpath::Rails::SessionsController, type: :controller do
  it { should be_a Stormpath::Rails::BaseController }

  describe "GET #new" do
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
  end

  describe "POST #create" do
    context "valida user params" do
      let(:user) { create(:user) }

      before do
        post :create, session: user.attributes.merge(password: "Password1337") 
      end

      it "redirects to root_path with succesfull message" do
        expect(flash[:notice]).to eq('Successfully signed in')
        expect(response).to redirect_to(root_path)
      end

      it "initializes the session" do
        expect(session[:user_id]).to_not be_nil
      end
    end

    context "invalid user params" do
      let(:user) { create(:user) }

      it "renders new template with errors" do
        post :create, session: user.attributes

        expect(flash[:error]).to_not be_nil
        expect(response).to render_template(:new)
      end
    end
  end


  describe "GET #redirect" do
    let(:user) { create(:user) }
    it "redirects to root_path" do
      allow(controller).to receive(:handle_id_site_callback).and_return(user)
      get :redirect

      expect(response).to redirect_to(root_path)
    end
  end

  describe "DELTE #destroy" do
    it "signs out the user" do
      sign_in
      delete :destroy

      expect(session[:user_id]).to be_nil
      expect(flash[:notice]).to eq('You have been logged out successfully.')
      expect(response).to redirect_to(root_path)
    end
  end

  describe "POST #create" do
    before do
      create_test_account
    end

    context "valid parameters" do
      it "signs in user" do
        post :create, session: { email: test_user.email, password: test_user.password }

        expect(response).to redirect_to(root_path)
        expect(flash[:notice]).to eq("Successfully signed in")
      end
    end

    context "invalid parameters" do
      it "renders new template with errors" do
        post :create, session: { email: "test@testable.com", password: test_user.password }

        expect(response).to be_success
        expect(response).to render_template(:new)
        expect(flash[:error]).to eq("Invalid username or password.")
      end
    end
  end
end
