require 'spec_helper'

describe "the signin process", type: :feature, vcr: true do
  # before :each do
  #   User.make(:email => 'user@example.com', :password => 'password')
  # end

  let(:login_config) { Stormpath::Rails.config.web.login }

  describe 'unauthenticated' do
    it "prompts error" do
      visit 'login'
      fill_in 'session_login', with: 'blah@example.com'
      fill_in 'session_password', with: 'password'
      click_button 'Log in'
      expect(page).to have_content 'Invalid username or password.'
    end

    it 'has proper labels' do
      visit 'login'
      expect(page).to have_css("label", text: "Username or Email")
      expect(page).to have_css("label", text: "Password")
    end

    it 'has proper labels when labels are changed' do
      allow(login_config.form.fields.login).to receive(:label).and_return('e-mail')
      allow(login_config.form.fields.password).to receive(:label).and_return('Passworten')

      visit 'login'
      expect(page).to have_css("label", text: "e-mail")
      expect(page).to have_css("label", text: "Passworten")
    end

    it 'has proper placeholders' do
      visit 'login'

      login_placeholder = find('#session_login')['placeholder']
      password_placeholder = find('#session_password')['placeholder']

      expect(login_placeholder).to eq('Username or Email')
      expect(password_placeholder).to eq('Password')
    end

    it 'has proper placeholders when placeholders are changed' do
      allow(login_config.form.fields.login).to receive(:placeholder).and_return('e-mail')
      allow(login_config.form.fields.password).to receive(:placeholder).and_return('Passworten')

      visit 'login'

      login_placeholder = find('#session_login')['placeholder']
      password_placeholder = find('#session_password')['placeholder']

      expect(login_placeholder).to eq('e-mail')
      expect(password_placeholder).to eq('Passworten')
    end
  end
end
