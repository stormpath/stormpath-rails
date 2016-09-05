require 'spec_helper'

describe Stormpath::Rails::AuthorizationCodeExchanger, vcr: true do
  let(:exchanger_class) { Stormpath::Rails::AuthorizationCodeExchanger }
  let(:exchanger) { exchanger_class.new(provider, root_url, params) }
  let(:root_url) { 'http://localhost:3000/' }
  let(:facebook_uri) { URI 'https://graph.facebook.com/v2.7/oauth/access_token' }

  describe 'facebook' do
    let(:provider) { :facebook }
    let(:params) { { code: Stormpath::Social::Helpers.mocked_authorization_code_for(:facebook) } }

    it 'should instantiate correct facebook uri' do
      expect(exchanger.uri).to eq facebook_uri
    end

    it 'should return access token' do
      allow(:exchanger_class).to receive(:access_token).and_return(Stormpath::Social::Helpers.mocked_access_token(:facebook))
      expect(exchanger.access_token).to eq Stormpath::Social::Helpers.mocked_access_token(:facebook)['access_token']
    end
  end

end
