require "spec_helper"

describe Stormpath::Rails::LogoutController, :vcr, type: :controller do
  it { should be_a Stormpath::Rails::BaseController }

  describe "POST #create" do
    context "application/json request" do
      it "signs out the user" do
        sign_in
        post :create, format: :json

        expect(response).to be_success
        expect(response.body).to be_empty
        expect(session[:user_id]).to be_nil
        expect(session[:href]).to be_nil
      end
    end

    it "signs out the user" do
      sign_in
      post :create

      expect(session[:user_id]).to be_nil
      expect(session[:href]).to be_nil
      expect(flash[:notice]).to eq('You have been logged out successfully.')
      expect(response).to redirect_to(root_path)
    end

    context "custom next_uri" do
      before do
        Stormpath::Rails.config.logout.next_uri = '/custom'
      end

      after { Stormpath::Rails.config.logout.reset_attributes }

      it "redirects to next_uri" do
        sign_in
        post :create

        expect(response).to redirect_to('/custom')
      end
    end
  end
end
