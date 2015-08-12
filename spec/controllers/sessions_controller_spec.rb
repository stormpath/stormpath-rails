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
        expect(flash[:notice]).to eq("Invalid username or password.")
      end
    end
  end
end