require 'spec_helper'

describe 'Github login', type: :request, vcr: true do
  let(:app_href) { URI Stormpath::Rails::Client.application.href }
  let(:auth_code_url) { 'https://github.com/login/oauth/authorize' }
  let(:access_token_auth_url) { 'https://github.com/login/oauth/access_token' }
  let(:authorization_code) { Stormpath::Social::Helpers.mocked_authorization_code_for(:github) }
  let(:access_token) { Stormpath::Social::Helpers.mocked_access_token_for(:github) }
  let(:error_code) { Stormpath::Social::Helpers.access_denied_response }
  let(:error_token) { Stormpath::Social::Helpers.code_mismatch }
  let(:mocked_account) { Stormpath::Social::Helpers.mocked_account(:github) }

  describe 'get https://github.com/login/oauth/authorize' do
    context 'when user accepts on github' do
      it 'should return authorization code' do
        stub_request(:get, auth_code_url).to_return(body: authorization_code)
        response = JSON.parse(Net::HTTP.get(URI(auth_code_url)))
        expect(response).to have_key('code')
      end
    end

    context 'when user denies on github' do
      it 'should return error response' do
        stub_request(:get, auth_code_url).to_return(body: error_code)
        response = JSON.parse(Net::HTTP.get(URI(auth_code_url)))
        expect(response).to have_key('error')
      end
    end
  end

  describe 'post https://github.com/login/oauth/access_token' do
    let(:gh_oauth) { URI 'https://github.com/login/oauth/access_token' }
    context 'when authorization code matches url' do
      it 'should return access token' do
        stub_request(:post, access_token_auth_url).to_return(body: access_token)
        protocol = Net::HTTP.new(gh_oauth.host, gh_oauth.port)
        protocol.use_ssl = true
        response = JSON.parse(
          protocol.post(
            gh_oauth, URI.encode_www_form(code: access_token), 'Accept' => 'application/json'
          ).body
        )
        expect(response).to have_key('access_token')
        expect(response).to have_key('token_type')
        expect(response).to have_key('scope')
      end
    end

    context "when authorization code doesn't match in the url" do
      it 'should return error response' do
        stub_request(:post, access_token_auth_url).to_return(body: error_token)
        response = JSON.parse(Net::HTTP.get(URI(access_token_auth_url)))
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
