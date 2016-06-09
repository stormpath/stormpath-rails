require 'spec_helper'

describe 'Content Type Routing Constraint', type: :request do
  it 'should be declined, invalid header' do
    post "/users", {}, 'HTTP_ACCEPT' => 'audio/mp3'

    expect(response.status).to eq(404)
  end
end
