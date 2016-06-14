require 'spec_helper'

describe 'Oauth2 GET', type: :request, vcr: true do
  it 'should respond with 405' do
    get '/oauth/token', {}, 'HTTP_ACCEPT' => 'application/json'
    expect(response.status).to eq(405)
  end
end
