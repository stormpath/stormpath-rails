require 'spec_helper'

describe Stormpath::Rails::PayloadBuilder, type: :service do
  Timecop.freeze(Time.zone.now) do
    let(:time) { Time.zone.now.to_i }
  end

  let(:jwt) do
    JWT.encode(
      {
        'iat' => time,
        'iss' => ENV['STORMPATH_API_KEY_ID'],
        'sub' => ENV['STORMPATH_APPLICATION_URL'],
        'cb_uri' => cb_uri,
        'jti' => 'secure_random_uuid',
        'path' => path,
        'state' => ''
      },
      ENV['STORMPATH_API_KEY_SECRET'],
      'HS256'
    )
  end

  before do
    allow(SecureRandom).to receive(:uuid).and_return('secure_random_uuid')
    allow(web_config.id_site).to receive(:enabled).and_return(true)
    Rails.application.reload_routes!
  end

  context 'login id site' do
    let(:cb_uri) { id_site_result_url }
    let(:path) { '' }

    it 'should return correct jwt for login id site' do
      expect(Stormpath::Rails::PayloadBuilder.new(:login, cb_uri: id_site_result_url).jwt).to eq jwt
    end
  end

  context 'when logout id site' do
    let(:cb_uri) { root_url }
    let(:path) { '' }

    it 'should return correct jwt for logout id site' do
      expect(Stormpath::Rails::PayloadBuilder.new(:logout, cb_uri: root_url).jwt).to eq jwt
    end
  end

  context 'when register id site' do
    let(:cb_uri) { id_site_result_url }
    let(:path) { '/#/register' }

    it 'should return correct jwt' do
      expect(Stormpath::Rails::PayloadBuilder.new(:register, cb_uri: id_site_result_url).jwt).to eq jwt
    end
  end
end
