require 'spec_helper'

describe Stormpath::Rails::Config::SocialLoginVerification, vcr: true do
  let!(:social_login_verification_class) { Stormpath::Rails::Config::SocialLoginVerification }
  let!(:social_login_verification) { social_login_verification_class.new(app_href, true) }
  let!(:app_href) { Stormpath::Rails::Client.application.href }
  let!(:app_name) { Stormpath::Rails::Client.application.name }

  describe 'with directories for social login set' do
    it 'should retrieve facebook directory' do
      expect(social_login_verification.facebook).to_not be nil
    end
  end
end
