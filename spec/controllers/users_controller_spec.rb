require "spec_helper"

describe Stormpath::UsersController, type: :controller do
  it { should be_a Stormpath::BaseController }

  describe "on GET to #new" do
    it "renders a form for a new user" do
      get :new

      expect(response).to be_success
      expect(response).to render_template(:new)
    end
  end
end