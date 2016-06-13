require 'spec_helper'

xdescribe Stormpath::Rails::OmniauthController, :vcr, type: :controller do
  it { should be_a Stormpath::Rails::BaseController }

  describe 'GET #create' do
    let(:access_token) { 'iw3k1m3n4jal20sd' }
    let(:account) do
      double(:account,
             email: 'example@test.com',
             given_name: 'name',
             surname: 'surname',
             href: '/testhref'
            )
    end
    let(:account_response) { double(:stormpath_account, account: account) }

    before do
      allow(Stormpath::Rails::Client).to receive(:create_omniauth_user)
        .with('facebook', access_token)
        .and_return(account_response)

      get :create, access_token: access_token
    end

    it 'redirects to root_path' do
      expect(response).to redirect_to(root_path)
    end

    it 'sets success flash message' do
      expect(flash[:notice]).to eq 'Successfully signed in'
    end
  end
end
