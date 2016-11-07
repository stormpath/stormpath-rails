require 'spec_helper'

describe Stormpath::Rails::FacebookAuthCodeExchange, vcr: true do
  let(:exchanger_class) { Stormpath::Rails::FacebookAuthCodeExchange }
  let(:exchanger) { exchanger_class.new(root_url, code) }
  let(:root_url) { 'http://localhost:3000/' }

  describe 'facebook' do
    let(:code) { Stormpath::Social::Helpers.mocked_authorization_code_for(:facebook) }

    it 'should return access token' do
      allow(exchanger).to receive(:access_token).and_return(Stormpath::Social::Helpers.mocked_access_token_for(:facebook))
      expect(exchanger.access_token).to eq Stormpath::Social::Helpers.mocked_access_token_for(:facebook)
    end
  end
end
