require 'spec_helper'

describe 'Logout POST', type: :request, vcr: true do
  before do
    Rails.application.reload_routes!
  end

  describe 'HTTP_ACCEPT=text/html' do
    describe 'html is enabled' do
      it 'successfull logout' do
        post '/logout'
        expect(response).to redirect_to('/')
        expect(response.status).to eq(302)
      end
    end

    describe 'html is disabled' do
      before do
        allow(Stormpath::Rails.config.web).to receive(:produces) { ['application/json'] }
        Rails.application.reload_routes!
      end

      it 'returns 404' do
        post '/logout'
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'HTTP_ACCEPT=application/json' do
    def json_logout_post
      post '/logout', nil, 'HTTP_ACCEPT' => 'application/json'
    end

    describe 'json is enabled' do
      it 'successfull logout should result with 200' do
        json_logout_post
        expect(response.status).to eq(200)
        expect(response.body).to be_blank
      end
    end

    describe 'json is disabled' do
      before do
        allow(Stormpath::Rails.config.web).to receive(:produces) { ['text/html'] }
        Rails.application.reload_routes!
      end

      it 'returns 404' do
        json_logout_post
        expect(response.status).to eq(404)
      end
    end
  end

  describe 'logout disabled' do
    before do
      allow(Stormpath::Rails.config.web.logout).to receive(:enabled) { false }
      Rails.application.reload_routes!
    end

    it 'returns 404' do
      post '/logout'
      expect(response.status).to eq(404)
    end
  end

  describe 'logout next_uri changed' do
    before { allow(Stormpath::Rails.config.web.logout).to receive(:next_uri).and_return('/abc') }

    it 'should redirect to next_uri' do
      post '/logout'
      expect(response).to redirect_to('/abc')
      expect(response.status).to eq(302)
    end
  end
end
