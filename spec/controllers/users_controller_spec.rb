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

    context "when signed in" do
      it "redirects to the root url" do
      end
    end
  end
end