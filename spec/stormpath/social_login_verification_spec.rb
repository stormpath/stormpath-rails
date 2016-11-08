require 'spec_helper'

describe Stormpath::Rails::Config::SocialLoginVerification, vcr: true do
  let!(:social_login_verification_class) { Stormpath::Rails::Config::SocialLoginVerification }
  let!(:verification) { social_login_verification_class.new(app_href) }
  let!(:app_href) { Stormpath::Rails::Client.application.href }

  describe 'with directories for social login set' do
    describe 'directories should contain providers' do
      it 'should retrieve facebook provider' do
        expect(verification.facebook_app_id).to be
      end

      it 'should retrieve google provider' do
        expect(verification.google_app_id).to be
      end

      it 'should retrieve github provider' do
        expect(verification.github_app_id).to be
      end

      it 'should retrieve linkedin provider' do
        expect(verification.linkedin_app_id).to be
      end
    end
  end
end
