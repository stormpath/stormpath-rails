require 'spec_helper'

xdescribe Stormpath::Rails::Social do
  let(:class_with_social) do
    class SocialTest < Stormpath::Rails::BaseController
      include Stormpath::Rails::Controller
    end
  end

  subject { class_with_social.new }

  describe '#facebook_login_enabled?' do
    context 'set to false' do
      before do
        disable_facebook_login
      end

      it 'return false' do
        expect(subject.send(:facebook_login_enabled?)).to be false
      end
    end

    context 'set to true' do
      before do
        enable_facebook_login
      end

      it 'return true' do
        expect(subject.send(:facebook_login_enabled?)).to be true
      end
    end
  end

  describe '#facebook_app_id' do
    before do
      enable_facebook_login
    end

    it 'return true' do
      expect(subject.send(:facebook_app_id)).to eq 'test_app_id'
    end
  end
end
