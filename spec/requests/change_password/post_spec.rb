require 'spec_helper'

xdescribe 'ChangePassword POST', type: :request, vcr: true do
  let(:user) { Stormpath::Rails::Client.application.accounts.create(user_attrs) }

  let(:user_attrs) do
    { email: 'example@test.com', given_name: 'Example', surname: 'Test', password: 'Pa$$W0RD', username: 'SirExample' }
  end

  before do
    user
    enable_change_password
    Rails.application.reload_routes!
  end

  after { user.delete }

  context 'application/json' do
    def json_change_post(attrs)
      post '/change', attrs, { 'HTTP_ACCEPT' => 'application/json' }
    end

    context "valid data" do
      it "return 200 OK" do
        json_change_post(email: user.email)
        expect(response).to be_success
      end
    end

    context "invalid data" do
      it "return 200 OK" do
        json_change_post(password: { email: "test@testable.com" })
        expect(response).to be_success
      end
    end
  end

  context 'text/html' do
    context "valid data" do
      it "redirects to login" do
        post '/change', password: { email: test_user.email }
        expect(response).to redirect_to('/login?status=forgot')
      end
    end

    context "invalid data" do
      it 'with wrong email redirects to login' do
        post '/change', password: { email: "test@testable.com" }
        expect(response).to redirect_to('/login?status=forgot')
      end

      it "with no email redirects to login" do
        post '/change', password: { email: "" }
        expect(response).to redirect_to('/login?status=forgot')
      end
    end
  end
end
