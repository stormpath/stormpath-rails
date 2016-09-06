require 'spec_helper'

describe 'Google login', type: :request, vcr: true do
  let(:app_href) { URI Stormpath::Rails::Client.application.href }
  let(:auth_url) { 'https://accounts.google.com/o/oauth2/auth' }
  let(:access_token) { Stormpath::Social::Helpers.mocked_access_token_for(:google) }
  let(:error_code) { Stormpath::Social::Helpers.access_denied_response }
  let(:error_token) { Stormpath::Social::Helpers.code_mismatch }
  let(:mocked_account) { Stormpath::Social::Helpers.mocked_account(:google) }

  describe 'get https://accounts.google.com/o/oauth2/auth' do
    context 'when user accepts on google' do
      it 'should return authorization code' do
        stub_request(:get, auth_url).to_return(body: access_token)
        response = JSON.parse(Net::HTTP.get(URI(auth_url)))
        expect(response).to have_key('code')
      end
    end

    context 'when user denies on google' do
      it 'should return error response' do
        stub_request(:get, auth_url).to_return(body: error_code)
        response = JSON.parse(Net::HTTP.get(URI(auth_url)))
        expect(response).to have_key('error')
      end
    end
  end

  describe 'post stormpath /accounts' do
    it 'should return account' do
      stub_request(:post, app_href).to_return(body: mocked_account, status: 200)
      protocol = Net::HTTP.new(app_href.host, app_href.port)
      protocol.use_ssl = true
      response = JSON.parse(
        protocol.post(
          app_href, URI.encode_www_form(code: access_token), 'Accept' => 'application/json'
        ).body
      )
      expect(response).to have_key('href')
      expect(response).to have_key('username')
      expect(response).to have_key('email')
    end
  end
end
