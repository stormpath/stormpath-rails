require 'spec_helper'

describe 'access usage feature', type: :feature, vcr: true do
  let(:login_config) { configuration.web.login }

  describe 'POST /login' do
    describe 'proper email and password' do
      let(:user) { create_test_account }

      after { delete_test_account }

      it 'has access to his profile if signed in' do
        visit 'login'
        fill_in 'Username or Email', with: user.email
        fill_in 'Password', with: 'Password1337'
        click_button 'Log in'
        expect(page).to have_content 'Root page'
        visit 'my_profile'
        expect(page).to have_content user.email
      end

      it "doesn't have access to his profile if not signed in" do
        visit 'my_profile'
        expect(page).to have_content 'Log in or Create Account'
      end
    end
  end
end
