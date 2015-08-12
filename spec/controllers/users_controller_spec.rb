require "spec_helper"

describe Stormpath::Rails::UsersController, type: :controller do
  it { should be_a Stormpath::Rails::BaseController }

  before do
    create_test_account
  end

  after do
    delete_test_account
  end

  describe "on GET to #new" do
    context "when signed out" do
      it "renders a form for a new user" do
        get :new

        expect(response).to be_success
        expect(response).to render_template(:new)
      end
    end
  end

  describe "on POST to #create" do
    let(:user_attributes) { attributes_for(:user) }

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
        expect(response).to render_template(:verified)
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