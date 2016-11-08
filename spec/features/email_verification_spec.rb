require 'spec_helper'

describe 'the email verification feature', type: :feature, vcr: true do
  let(:application) { test_application }
  let(:test_dir_with_verification) do
    Stormpath::Rails::Client.client.directories.create(name: 'rails test dir with verification')
  end
  let(:account) { test_dir_with_verification.accounts.create(account_attrs) }
  let(:account_attrs) { FactoryGirl.attributes_for(:account) }
  let(:sptoken) { account.email_verification_token.token }

  before do
    enable_email_verification_for(test_dir_with_verification)
    map_account_store(application, test_dir_with_verification, 2, false, false)
    enable_email_verification
    Rails.application.reload_routes!
    account
  end

  after do
    test_dir_with_verification.delete
    account.delete
  end

  describe 'GET /verify' do
    describe 'with no sptoken' do
      it 'has proper labels' do
        visit 'verify'
        expect(page).to have_css('label', text: 'Email')
      end

      it 'has proper placeholders' do
        visit 'verify'
        expect(find_field('email')['placeholder']).to eq('Email')
      end

      it 'has proper text' do
        visit 'verify'
        expect(page).to have_content(
          "Enter your email address below and we'll resend your account
          verification email.  You will be sent an email which you will
          need to open to continue. You may need to check your spam
          folder."
        )
      end

      it 'does not blow up with wrong path helpers when login is disabled' do
        allow(configuration.web.login).to receive(:enabled).and_return(false)

        Rails.application.reload_routes!

        visit 'verify'

        expect(page.status_code).to eq(200)
        expect(page).not_to have_content('Back to Log In')
      end
    end

    describe 'with invalid sptoken' do
      it 'renders form with error text' do
        visit 'verify?sptoken=INVALID-SPTOKEN'
        expect(page).to have_content(
          'This verification link is no longer valid. '\
          'Please request a new link from the form below.'
        )
      end
    end

    describe 'with valid sptoken' do
      it 'redirects to login uri' do
        visit "verify?sptoken=#{sptoken}"
        expect(page).to have_current_path('/login?status=verified')
      end

      context 'auto login enabled' do
        before do
          allow(configuration.web.register).to receive(:auto_login).and_return(true)
        end

        it 'redirects to root and sets cookies' do
          visit "verify?sptoken=#{sptoken}"

          expect(current_path).to eq('/')
          expect(page).to have_content 'Root page'
          expect(page.driver.request.cookies['access_token']).to be
          expect(page.driver.request.cookies['refresh_token']).to be
        end
      end
    end
  end

  describe 'POST /verify' do
    context 'auto login disabled' do
      it 'redirects to login page with status unverified' do
        visit 'verify'
        fill_in 'email', with: account.email
        click_button 'Submit'
        expect(page).to have_current_path('/login?status=unverified')
        expect(page).to have_content(
          'Your account verification email has been sent! Before you can log into your account, '\
          'you need to activate your account by clicking the link we sent to your inbox. '\
          'Didn\'t get the email?'
        )
      end
    end
  end
end
