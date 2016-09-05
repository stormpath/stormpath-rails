require 'spec_helper'

describe Stormpath::Rails::GithubAuthCodeExchange, vcr: true do
  let(:exchanger_class) { Stormpath::Rails::GithubAuthCodeExchange }
  let(:exchanger) { exchanger_class.new(root_url, code) }
  let(:root_url) { 'http://localhost:3000/' }

  describe 'github' do
    let(:code) { Stormpath::Social::Helpers.mocked_authorization_code_for(:github) }

    it 'should return access token' do
      allow(:exchanger_class).to receive(:access_token).and_return(Stormpath::Social::Helpers.mocked_access_token(:github))
      expect(exchanger.access_token).to eq Stormpath::Social::Helpers.mocked_access_token(:github)['access_token']
    end
  end

end
