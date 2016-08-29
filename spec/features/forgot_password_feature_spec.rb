require 'spec_helper'

describe 'the forgot password feature', type: :feature, vcr: true do
  let(:forgot_password_config) { configuration.web.forgot_password }

  let(:account) { Stormpath::Rails::Client.application.accounts.create(account_attrs) }

  let(:account_attrs) { FactoryGirl.attributes_for(:account) }

  before { Rails.application.reload_routes! }
  after { account.delete }

  describe 'GET /forgot' do
    it 'has proper labels' do
      visit 'forgot'
      expect(page).to have_css('label', text: 'Email')
    end

    it 'has proper placeholders' do
      visit 'forgot'
      expect(find_field('email')['placeholder']).to eq('Email')
    end

    it 'should render the page when login is disabled' do
      allow(configuration.web.login).to receive(:enabled).and_return(false)

      Rails.application.reload_routes!

      visit 'forgot'
      expect(page.status_code).to eq(200)
      expect(page).to have_content('Submit')
      expect(page).not_to have_content('Back to Log In')
    end
  end

  describe 'POST /forgot' do
    context 'valid email' do
      it 'redirects to root and sets cookies' do
        visit 'forgot'
        fill_in 'Email', with: account.email
        click_button 'Submit'

        expect(page).to have_current_path('/login?status=forgot')
        expect(page).to have_content 'Password Reset Requested. If an account exists for the email provided, you will receive an email shortly.'
      end
    end

    context 'invalid email' do
      it 'redirects to root and sets cookies' do
        visit 'forgot'
        fill_in 'Email', with: account.email
        click_button 'Submit'

        expect(page).to have_current_path('/login?status=forgot')
        expect(page).to have_content 'Password Reset Requested. If an account exists for the email provided, you will receive an email shortly.'
      end
    end

    context 'blank email' do
      it 'redirects to root and sets cookies' do
        visit 'forgot'
        click_button 'Submit'

        expect(page).to have_current_path('/forgot')
        expect(page).to have_content 'Email parameter not provided.'
      end
    end
  end
end
