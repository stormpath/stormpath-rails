require 'spec_helper'

describe Stormpath::Rails::Config::SocialLoginVerification, vcr: true do
  let!(:social_login_verification_class) { Stormpath::Rails::Config::SocialLoginVerification }
  let!(:verification) { social_login_verification_class.new(app_href, true) }
  let!(:app_href) { Stormpath::Rails::Client.application.href }
  let!(:app_name) { Stormpath::Rails::Client.application.name }

  describe 'with directories for social login set' do
    describe 'directories should contain providers' do
      it 'should retrieve facebook provider' do
        expect(verification.facebook.provider.provider_id).to eq 'facebook'
      end

      it 'should retrieve google provider' do
        expect(verification.google.provider.provider_id).to eq 'google'
      end

      it 'should retrieve github provider' do
        expect(verification.github.provider.provider_id).to eq 'github'
      end

      it 'should retrieve linkedin provider' do
        expect(verification.linkedin.provider.provider_id).to eq 'linkedin'
      end
    end
  end
end
