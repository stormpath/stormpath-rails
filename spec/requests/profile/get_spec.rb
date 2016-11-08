require 'spec_helper'

describe 'Me GET', type: :request, vcr: true do
  def response_body
    JSON.parse(response.body)
  end

  let(:account) { Stormpath::Rails::Client.application.accounts.create(account_attrs) }

  let(:account_attrs) { FactoryGirl.attributes_for(:account) }

  after { account.delete }

  context 'when logged in successfully' do
    before do
      post '/login', login: account.email, password: account_attrs[:password]
    end

    context 'application/json' do
      def json_me_get
        get '/me', {}, 'HTTP_ACCEPT' => 'application/json'
      end

      context 'me enabled' do
        before do
          enable_profile
          Rails.application.reload_routes!
        end

        it 'return 200' do
          json_me_get
          expect(response.status).to eq(200)
        end

        it 'matches schema' do
          json_me_get
          expect(response).to match_response_schema(:login_response, strict: true)
        end

        it 'sets proper headers' do
          json_me_get
          expect(response.headers['Cache-Control']).to eq('no-cache, no-store')
          expect(response.headers['Pragma']).to eq('no-cache')
        end

        describe 'totally expanded' do
          let(:expansion) do
            OpenStruct.new(
              api_keys: false,
              applications: true,
              custom_data: true,
              directory: true,
              group_memberships: true,
              groups: true,
              provider_data: true,
              tenant: true
            )
          end

          before do
            allow(web_config.me).to receive(:expand).and_return(expansion)
          end

          it 'matches schema' do
            json_me_get
            expect(response).to match_response_schema(:profile_response, strict: true)
          end
        end
      end

      context 'me disabled' do
        before do
          disable_profile
          Rails.application.reload_routes!
        end

        it 'return 404' do
          json_me_get
          expect(response.status).to eq(404)
        end
      end
    end

    context 'text/html' do
      context 'me enabled' do
        before do
          enable_profile
          Rails.application.reload_routes!
        end

        it 'renders json view' do
          get '/me'
          expect(response).to be_success
        end
      end

      context 'me disabled' do
        before do
          disable_profile
          Rails.application.reload_routes!
        end

        it 'renders 404' do
          get '/me'
          expect(response.status).to eq(404)
        end
      end
    end
  end

  context 'when not logged in' do
    def json_me_get
      get '/me', {}, 'HTTP_ACCEPT' => 'application/json'
    end

    before do
      enable_profile
      Rails.application.reload_routes!
    end

    it 'should render nothing' do
      json_me_get
      expect(response.body).to be_blank
    end

    it 'should have status 401' do
      json_me_get
      expect(response.status).to eq 401
    end

    it 'should have WWW-Authenticate headers' do
      json_me_get
      expect(response.headers).to include('WWW-Authenticate')
      expect(response.headers['WWW-Authenticate']).to eq "Bearer realm=\"My Application\""
    end
  end
end
