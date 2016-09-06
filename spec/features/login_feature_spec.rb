require 'spec_helper'

describe 'the login feature', type: :feature, vcr: true do
  let(:login_config) { configuration.web.login }

  before { Rails.application.reload_routes! }

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

    it 'does not blow up with wrong path helpers when register is disabled' do
      allow(configuration.web.register).to receive(:enabled).and_return(false)

      Rails.application.reload_routes!

      visit 'login'

      expect(page.status_code).to eq(200)
      expect(page).to have_content('Log in')
    end

    describe 'shows social logins if directories available' do
      context 'when facebook is available' do
        it 'should show a facebook login link' do
          allow(configuration.web).to receive(:facebook_app_id).and_return('random_string')
          Rails.application.reload_routes!

          visit 'login'
          expect(page).to have_content('Facebook')
        end
      end

      context 'when facebook is not available' do
        it 'should not show facebook login link' do
          allow(configuration.web).to receive(:facebook_app_id).and_return(nil)
          Rails.application.reload_routes!

          visit 'login'
          expect(page).not_to have_content('Facebook')
        end
      end

      context 'when google is available' do
        it 'should show a google login link' do
          allow(configuration.web).to receive(:google_app_id).and_return('random_string')
          Rails.application.reload_routes!

          visit 'login'
          expect(page).to have_content('Google')
        end
      end

      context 'when google is not available' do
        it 'should not show google login link' do
          allow(configuration.web).to receive(:google_app_id).and_return(nil)
          Rails.application.reload_routes!

          visit 'login'
          expect(page).not_to have_content('Google')
        end
      end

      context 'when github is available' do
        it 'should show a github login link' do
          allow(configuration.web).to receive(:github_app_id).and_return('random_string')
          Rails.application.reload_routes!

          visit 'login'
          expect(page).to have_content('GitHub')
        end
      end

      context 'when github is not available' do
        it 'should not show github login link' do
          allow(configuration.web).to receive(:github_app_id).and_return(nil)
          Rails.application.reload_routes!

          visit 'login'
          expect(page).not_to have_content('GitHub')
        end
      end

      context 'when linkedin is available' do
        it 'should show a linkedin login link' do
          allow(configuration.web).to receive(:linkedin_app_id).and_return('random_string')
          Rails.application.reload_routes!

          visit 'login'
          expect(page).to have_content('LinkedIn')
        end
      end

      context 'when linkedin is not available' do
        it 'should not show linkedin login link' do
          allow(configuration.web).to receive(:linkedin_app_id).and_return(nil)
          Rails.application.reload_routes!

          visit 'login'
          expect(page).not_to have_content('LinkedIn')
        end
      end
    end

    it 'does not blow up with wrong path helpers when forgot_password is disabled' do
      allow(configuration.web.forgot_password).to receive(:enabled).and_return(false)

      Rails.application.reload_routes!

      visit 'login'

      expect(page.status_code).to eq(200)
      expect(page).to have_content('Log in')
    end

    it 'does not blow up with wrong path helpers when verify_email is disabled' do
      allow(configuration.web.verify_email).to receive(:enabled).and_return(false)

      Rails.application.reload_routes!

      visit 'login'

      expect(page.status_code).to eq(200)
      expect(page).not_to have_content('Click Here')
      expect(page).to have_content('Log in')
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
      allow(configuration.web.forgot_password).to receive(:enabled).and_return(false)
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
        expect(page).to have_content "Username or Email can't be blank"
      end

      it 'missing login field' do
        visit 'login'
        fill_in 'Password', with: 'password'
        click_button 'Log in'
        expect(page).to have_content "Username or Email can't be blank"
      end

      it 'missing password field' do
        visit 'login'
        fill_in 'Username or Email', with: 'blah@example.com'
        click_button 'Log in'
        expect(page).to have_content "Password can't be blank"
      end
    end

    describe 'proper email and password' do
      let(:account) { create_test_account }

      after { delete_test_account }

      it 'redirects to root page' do
        visit 'login'
        fill_in 'Username or Email', with: account.email
        fill_in 'Password', with: 'Password1337'
        click_button 'Log in'
        expect(page).to have_content 'Root page'
      end

      it 'sets cookies' do
        visit 'login'
        fill_in 'Username or Email', with: account.email
        fill_in 'Password', with: 'Password1337'
        click_button 'Log in'
        expect(page.driver.request.cookies['access_token']).to be
        expect(page.driver.request.cookies['refresh_token']).to be
      end

      xit 'when root page has authentication over it self'

      it 'with changed next uri' do
        allow(login_config).to receive(:next_uri).and_return('/about')

        visit 'login'
        fill_in 'Username or Email', with: account.email
        fill_in 'Password', with: 'Password1337'
        click_button 'Log in'
        expect(page).to have_content 'About us'
      end

      it 'referered from another page'
    end
  end

  describe 'describe login referer' do
    let(:account) { create_test_account }

    after { account.delete }

    it 'given the account vistis login page with a next param pointing to /my_profile' do
      visit 'login?next=/my_profile'
      fill_in 'Username or Email', with: account.email
      fill_in 'Password', with: 'Password1337'
      click_button 'Log in'
      expect(page).to have_current_path('/my_profile')
    end

    it 'given the account vistis login page with a next param pointing to /my_profile' do
      visit 'login?next=https://www.fake-stormpath.com/my_profile'
      fill_in 'Username or Email', with: account.email
      fill_in 'Password', with: 'Password1337'
      click_button 'Log in'
      expect(page).to have_current_path('/my_profile')
    end

    it 'given the user is redirected to the login page with a next param pointing to my_profile' do
      visit 'my_profile'
      fill_in 'Username or Email', with: account.email
      fill_in 'Password', with: 'Password1337'
      click_button 'Log in'
      expect(page).to have_current_path('/my_profile')
    end
  end

  describe 'saml' do
    it 'saml'
  end
end
