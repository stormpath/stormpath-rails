require 'spec_helper'

describe 'the signin process', type: :feature, vcr: true do
  let(:login_config) { Stormpath::Rails.config.web.login }

  describe 'GET /login' do
    it 'has proper labels' do
      visit 'login'
      expect(page).to have_css('label', text: 'Username or Email')
      expect(page).to have_css('label', text: 'Password')
    end

    it 'has proper labels when labels are changed' do
      allow(login_config.form.fields.login).to receive(:label).and_return('e-mail')
      allow(login_config.form.fields.password).to receive(:label).and_return('Passworten')

      visit 'login'
      expect(page).to have_css('label', text: 'e-mail')
      expect(page).to have_css('label', text: 'Passworten')
    end

    let(:login_placeholder) { find_field('login')['placeholder'] }
    let(:password_placeholder) { find_field('password')['placeholder'] }

    it 'has proper placeholders' do
      visit 'login'
      expect(login_placeholder).to eq('Username or Email')
      expect(password_placeholder).to eq('Password')
    end

    it 'has proper placeholders when placeholders are changed' do
      allow(login_config.form.fields.login).to receive(:placeholder).and_return('e-mail')
      allow(login_config.form.fields.password).to receive(:placeholder).and_return('Passworten')

      visit 'login'
      expect(password_placeholder).to eq('Passworten')
      expect(login_placeholder).to eq('e-mail')
    end

    it 'hides login field if enabled set to false' do
      allow(login_config.form.fields.login).to receive(:enabled).and_return(false)

      visit 'login'

      expect { find_field('login') }.to raise_error(Capybara::ElementNotFound)
    end

    it 'hides login field if visible set to false' do
      allow(login_config.form.fields.login).to receive(:visible).and_return(false)

      visit 'login'

      expect { find_field('login') }.to raise_error(Capybara::ElementNotFound)
    end

    xit 'shows social logins when needed' do
    end

    xit 'SAML' do
    end

    xit 'default view' do
      # NEED more info on this
    end

    it 'shows forgot password link when enabled' do
      visit 'login'
      expect(page).to have_selector(:link_or_button, 'Forgot Password?')
    end

    it 'shows forgot password link when disabled' do
      allow(Stormpath::Rails.config.web.forgot_password).to receive(:enabled).and_return(false)
      visit 'login'
      expect(page).not_to have_selector(:link_or_button, 'Forgot Password?')
    end
  end

  describe 'POST /login' do
    describe 'wrong email or password' do
      it 'prompts error' do
        visit 'login'
        fill_in 'Username or Email', with: 'blah@example.com'
        fill_in 'Password', with: 'password'
        click_button 'Log in'
        expect(page).to have_content 'Invalid username or password.'
      end

      it 'preserves login field info' do
        visit 'login'
        fill_in 'Username or Email', with: 'blah@example.com'
        fill_in 'Password', with: 'password'
        click_button 'Log in'
        expect(find_field('login').value).to have_content 'blah@example.com'
      end
    end

    describe 'missing fields' do
      it 'missing both fields' do
        visit 'login'
        click_button 'Log in'
        expect(page).to have_content "Login and password fields can't be blank"
      end

      it 'missing login field' do
        visit 'login'
        fill_in 'Password', with: 'password'
        click_button 'Log in'
        expect(page).to have_content "Login field can't be blank"
      end

      it 'missing password field' do
        visit 'login'
        fill_in 'Username or Email', with: 'blah@example.com'
        click_button 'Log in'
        expect(page).to have_content "Password field can't be blank"
      end
    end

    describe 'proper email and password' do
      let(:user) { create_test_account.response }

      after { delete_test_account }

      it 'redirects to root page' do
        visit 'login'
        fill_in 'Username or Email', with: user.email
        fill_in 'Password', with: 'Password1337'
        click_button 'Log in'
        expect(page).to have_content 'Root page'
      end

      xit 'when root page has authentication over it self'

      it 'with changed next uri' do
        allow(login_config).to receive(:next_uri).and_return('/about')

        visit 'login'
        fill_in 'Username or Email', with: user.email
        fill_in 'Password', with: 'Password1337'
        click_button 'Log in'
        expect(page).to have_content 'About us'
      end

      it 'referered from another page'
    end
  end

  describe 'social login' do
    it 'facebook'
    it 'google'
    it 'github'
    it 'linkedin'
  end

  describe 'saml' do
    it 'saml'
  end
end
