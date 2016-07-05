require 'spec_helper'

describe Stormpath::Rails::ControllerAuthentication, vcr: true, type: :service do
  let(:account) { create_test_account }

  let(:password_grant_request) do
    Stormpath::Oauth::PasswordGrantRequest.new('jlc@example.com', 'Password1337')
  end

  let(:application) { Stormpath::Rails::Client.application }

  let(:access_token_authentication_result) do
    application.authenticate_oauth(password_grant_request)
  end

  let(:access_token) { access_token_authentication_result.access_token }

  let(:refresh_token) { access_token_authentication_result.refresh_token }

  let(:expired_token) do
    'eyJraWQiOiI2VTRIWk1IR0VZMEpHV1ZITjBVVU81QkdXIiwiYWxnIjoiSFMyNTYifQ.eyJqdGkiOiI0MTFwUFh6QlQ1Qmo4ckM2VVZBbGRQIiwiaWF0IjoxNDY0MTc3NzMyLCJpc3MiOiJodHRwczovL2FwaS5zdG9ybXBhdGguY29tL3YxL2FwcGxpY2F0aW9ucy8zblpsTEtWTUlPUHU3MVlDN1RGUjBvIiwic3ViIjoiaHR0cHM6Ly9hcGkuc3Rvcm1wYXRoLmNvbS92MS9hY2NvdW50cy80MDMxTkF2UU9HNEZJMldXSjhRNjExIiwiZXhwIjoxNDY0MTgxMzMyLCJydGkiOiI0MTFwUFVmNllVc2tXMjZGSUZKVjFMIn0.ltcEQqkVnMutBQItQehVn2ckXwsxnBjfTucFIuoGVNY'
  end

  let(:controller) do
    Stormpath::Rails::BaseController.new.tap do |controller|
      controller.request = request
    end
  end

  let(:request) do
    ActionDispatch::Request.new(
      'HTTP_COOKIE' => "access_token=#{access_token};refresh_token=#{refresh_token}"
    )
  end

  let(:controller_authenticator) do
    Stormpath::Rails::ControllerAuthentication.new(
      controller.send(:cookies),
      controller.request.headers['Authorization']
    )
  end

  before do
    account
    access_token_authentication_result
  end

  after { delete_test_account }

  describe 'cookie authentication' do
    describe 'with valid access token cookie' do
      it 'retrieves the account from access token' do
        current_account = controller_authenticator.authenticate!
        expect(current_account).to eq(account)
      end
    end

    describe 'with no cookies' do
      let(:request) do
        ActionDispatch::Request.new('HTTP_COOKIE' => '')
      end

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end
    end

    describe 'with expired access token' do
      let(:request) do
        ActionDispatch::Request.new(
          'HTTP_COOKIE' => "access_token=#{expired_token};refresh_token=#{refresh_token}"
        )
      end

      it 'retrieves the account from refresh token' do
        current_account = controller_authenticator.authenticate!
        expect(current_account).to eq(account)
      end

      it 'sets new cookies' do
        controller_authenticator.authenticate!
        expect(controller.send(:cookies)['access_token']).to be
        expect(controller.send(:cookies)['access_token']).not_to eq(expired_token)
        expect(controller.send(:cookies)['refresh_token']).to be
      end
    end

    describe 'with expired access token & expired refresh token' do
      let(:request) do
        ActionDispatch::Request.new(
          'HTTP_COOKIE' => "access_token=#{expired_token};refresh_token=#{expired_token}"
        )
      end

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end

      it 'deletes cookies' do
        begin
          controller_authenticator.authenticate!
        rescue Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest
        end
        expect(controller.send(:cookies)['access_token']).not_to be
        expect(controller.send(:cookies)['refresh_token']).not_to be
      end
    end

    describe 'with expired access token only' do
      let(:request) do
        ActionDispatch::Request.new(
          'HTTP_COOKIE' => "access_token=#{expired_token}"
        )
      end

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end

      it 'deletes cookies' do
        begin
          controller_authenticator.authenticate!
        rescue Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest
        end
        expect(controller.send(:cookies)['access_token']).not_to be
        expect(controller.send(:cookies)['refresh_token']).not_to be
      end
    end

    describe 'with invalid access and invalid refresh token' do
      let(:request) do
        ActionDispatch::Request.new(
          'HTTP_COOKIE' => 'access_token=INVALID_TOKEN;refresh_token=INVALID_TOKEN'
        )
      end

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end

      it 'deletes cookies' do
        begin
          controller_authenticator.authenticate!
        rescue Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest
        end
        expect(controller.send(:cookies)['access_token']).not_to be
        expect(controller.send(:cookies)['refresh_token']).not_to be
      end
    end

    describe 'with invalid refresh token only' do
      let(:request) do
        ActionDispatch::Request.new(
          'HTTP_COOKIE' => 'refresh_token=INVALID_TOKEN'
        )
      end

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end

      it 'deletes cookies' do
        begin
          controller_authenticator.authenticate!
        rescue Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest
        end
        expect(controller.send(:cookies)['access_token']).not_to be
        expect(controller.send(:cookies)['refresh_token']).not_to be
      end
    end

    describe 'with refresh token only' do
      let(:request) do
        ActionDispatch::Request.new('HTTP_COOKIE' => "refresh_token=#{refresh_token}")
      end

      it 'retrieves the account from refresh token' do
        current_account = controller_authenticator.authenticate!
        expect(current_account).to eq(account)
      end

      it 'sets new cookies' do
        controller_authenticator.authenticate!
        expect(controller.send(:cookies)['access_token']).to be
        expect(controller.send(:cookies)['refresh_token']).to be
      end
    end

    describe 'with refresh token at the access token place' do
      let(:request) do
        ActionDispatch::Request.new('HTTP_COOKIE' => "access_token=#{refresh_token}")
      end

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end

      it 'deletes cookies' do
        begin
          controller_authenticator.authenticate!
        rescue Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest
        end
        expect(controller.send(:cookies)['access_token']).not_to be
        expect(controller.send(:cookies)['refresh_token']).not_to be
      end
    end
  end

  describe 'bearer authentication' do
    describe 'with valid token' do
      let(:request) do
        ActionDispatch::Request.new('HTTP_AUTHORIZATION' => "Bearer #{access_token}")
      end

      it 'retrieves the account from access token' do
        current_account = controller_authenticator.authenticate!
        expect(current_account).to eq(account)
      end
    end

    describe 'with expired token' do
      let(:request) do
        ActionDispatch::Request.new('HTTP_AUTHORIZATION' => "Bearer #{expired_token}")
      end

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end
    end

    describe 'with malformed token' do
      let(:request) do
        ActionDispatch::Request.new('HTTP_AUTHORIZATION' => "Bearer INVALID-TOKEN")
      end

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end
    end

    describe 'with empty token' do
      let(:request) do
        ActionDispatch::Request.new('HTTP_AUTHORIZATION' => "Bearer  ")
      end

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end
    end
  end

  describe 'basic authentication' do
    let(:api_key) { account.api_keys.create({}) }

    let(:request) do
      ActionDispatch::Request.new('HTTP_AUTHORIZATION' => "Basic #{credentials}")
    end

    describe 'with valid api key id and secret' do
      let(:credentials) { Base64.encode64("#{api_key.id}:#{api_key.secret}") }

      it 'retrieves the account' do
        current_account = controller_authenticator.authenticate!
        expect(current_account).to eq(account)
      end
    end

    describe 'with only api key and no secret' do
      let(:credentials) { Base64.encode64(api_key.id) }

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end
    end

    describe 'with non-existing api key and secret' do
      let(:credentials) { Base64.encode64("dahgf3q4234fsd:bvcbfgt54332") }

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end
    end

    describe 'with api key and wrong secret' do
      let(:credentials) { Base64.encode64("#{api_key.id}:2aAbsa3TDFDF") }

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end
    end

    describe 'with un encoded api key and secret' do
      let(:credentials) { "#{api_key.id}:#{api_key.secret}" }

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end
    end

    describe 'with empty token' do
      let(:credentials) { '' }

      it 'raises an UnauthenticatedRequest error' do
        expect do
          controller_authenticator.authenticate!
        end.to raise_error(Stormpath::Rails::ControllerAuthentication::UnauthenticatedRequest)
      end
    end
  end
end
