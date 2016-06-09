require 'spec_helper'

describe 'Login GET', type: :request, vcr: true do
  describe 'HTTP_ACCEPT=application/json' do
    def json_login_get
      get '/login', {}, 'HTTP_ACCEPT' => 'application/json'
    end

    describe 'json is enabled' do
      it 'respond with status 200' do
        json_login_get
        expect(response.status).to eq(200)
      end

      it 'respond with content-type application/json' do
        json_login_get
        expect(response.content_type.to_s).to eq('application/json')
      end

      xit 'should match schema' do
        json_login_get
        expect(response).to match_response_schema(:login_response, strict: true)
      end

      it 'should match json' do
        json_login_get
        expect(response).to match_json <<-JSON
        {
        	"form": {
        		"fields": [{
        			"label": "Username or Email",
        			"name": "login",
        			"placeholder": "Username or Email",
        			"required": true,
        			"type": "text"
        		}, {
        			"label": "Password",
        			"name": "password",
        			"placeholder": "Password",
        			"required": true,
        			"type": "password"
        		}]
        	},
        	"accountStores": []
        }
        JSON
      end

      xit 'login should show account stores' do
      end

      xit 'if id site enabled should redirect' do
        json_login_get
        expect(response.status).to eq(400)
      end
    end

    describe 'json is disabled' do
      before do
        allow(Stormpath::Rails.config.web).to receive(:produces) { ['application/html'] }
        Rails.application.reload_routes!
      end

      it 'returns 404' do
        json_login_get
        expect(response.status).to eq(404)
      end
    end
  end
end
