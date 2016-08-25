require 'spec_helper'

describe 'the change password feature', type: :feature, vcr: true do
  let(:change_password_config) { configuration.web.change_password }

  let(:account) { Stormpath::Rails::Client.application.accounts.create(account_attrs) }

  let(:account_attrs) { FactoryGirl.attributes_for(:account) }

  let(:password_reset_token) do
    Stormpath::Rails::Client.application.password_reset_tokens.create(
      email: account.email
    ).token
  end

  after { account.delete }

  describe 'GET /change' do
    describe 'with no sptoken' do
      it 'redirects to forgot page' do
        visit 'change'
        expect(current_path).to eq('/forgot')
      end
    end

    describe 'with invalid sptoken' do
      it 'redirects to forgot page with invalid_sptoken status' do
        visit 'change?sptoken=INVALID-SPTOKEN'
        expect(page).to have_current_path('/forgot?status=invalid_sptoken')
      end
    end

    describe 'with valid sptoken' do
      it 'has proper labels' do
        visit "change?sptoken=#{password_reset_token}"
        expect(page).to have_css('label', text: 'Password')
      end

      it 'has proper placeholders' do
        visit "change?sptoken=#{password_reset_token}"
        expect(find_field('password')['placeholder']).to eq('Password')
      end
    end
  end

  describe 'POST /login' do
    let(:new_password) { 'neWpa$$W0Rd' }

    context 'valid sptoken' do
      context 'auto login enabled' do
        before do
          allow(change_password_config).to receive(:auto_login).and_return(true)
        end

        context 'valid password' do
          it 'redirects to root and sets cookies' do
            visit "change?sptoken=#{password_reset_token}"
            fill_in 'Password', with: new_password
            click_button 'Submit'

            expect(current_path).to eq('/')
            expect(page).to have_content 'Root page'
          end
        end
      end

      context 'auto login disabled' do
        context 'valid password' do
          it 'redirects to login page with status reset' do
            visit "change?sptoken=#{password_reset_token}"
            fill_in 'Password', with: new_password
            click_button 'Submit'
            expect(page).to have_current_path('/login?status=reset')
            expect(page).to have_content 'Password Reset Successfully. You can now login with your new password.'
          end
        end

        context 'invalid password first, valid second (sptoken in form persists)' do
          it 'redirects to login page with status reset' do
            visit "change?sptoken=#{password_reset_token}"
            fill_in 'Password', with: 'SHORT'
            click_button 'Submit'
            expect(current_path).to eq('/change')

            fill_in 'Password', with: new_password
            click_button 'Submit'
            expect(page).to have_content 'Password Reset Successfully. You can now login with your new password.'
          end
        end
      end

      context 'invalid password' do
        it 're renders form with error message' do
          visit "change?sptoken=#{password_reset_token}"
          fill_in 'Password', with: 'SHORT'
          click_button 'Submit'
          expect(current_path).to eq('/change')
          expect(page).to have_content 'Account password minimum length not satisfied.'
        end
      end

      context 'no password' do
        it 're renders form with error message' do
          visit "change?sptoken=#{password_reset_token}"
          click_button 'Submit'
          expect(current_path).to eq('/change')
          expect(page).to have_content 'account password is required; it cannot be null, empty, or blank.'
        end
      end
    end
  end
end
