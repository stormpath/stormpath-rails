require 'spec_helper'

describe 'the register feature', type: :feature, vcr: true do
  let(:register_config) { configuration.web.register }

  before do
    register_config.form.fields.middle_name.enabled = true
    register_config.form.fields.middle_name.required = false
    register_config.form.fields.confirm_password.enabled = true
    register_config.form.fields.phone_number = OpenStruct.new(
      enabled: true,
      visible: true,
      label: 'Phone Number',
      placeholder: 'Phone Number',
      required: true,
      type: 'text'
    )
    reload_form_class
  end

  after do
    register_config.form.fields.middle_name.enabled = false
    register_config.form.fields.middle_name.required = true
    register_config.form.fields.confirm_password.enabled = false
    register_config.form.fields.delete_field(:phone_number)
  end

  describe 'GET /register' do
    it 'has proper labels' do
      visit 'register'
      expect(page).to have_css('label', text: 'First Name')
      expect(page).to have_css('label', text: 'Last Name')
      expect(page).to have_css('label', text: 'Middle Name')
      expect(page).to have_css('label', text: 'Email')
      expect(page).to have_css('label', text: 'Phone Number')
      expect(page).to have_css('label', text: 'Password')
      expect(page).to have_css('label', text: 'Confirm Password')
    end

    it 'has proper placeholders' do
      visit 'register'
      expect(find_field('givenName')['placeholder']).to eq('First Name')
      expect(find_field('surname')['placeholder']).to eq('Last Name')
      expect(find_field('middleName')['placeholder']).to eq('Middle Name')
      expect(find_field('email')['placeholder']).to eq('Email')
      expect(find_field('phoneNumber')['placeholder']).to eq('Phone Number')
      expect(find_field('password')['placeholder']).to eq('Password')
      expect(find_field('confirmPassword')['placeholder']).to eq('Confirm Password')
    end
  end

  describe 'POST /register' do
    describe 'incorrect submission' do
      it 'prompts error' do
        visit 'register'

        fill_in 'givenName', with: 'Damir'
        fill_in 'surname', with: 'Svrtan'
        fill_in 'email', with: 'damir.svrtan@infinum-test.co'
        fill_in 'phoneNumber', with: '0931323232223'
        fill_in 'password', with: 'pa$$W0Rd'
        fill_in 'confirmPassword', with: 'pa$$W0Rtttt'

        click_button 'Create Account'
        expect(page).to have_content 'Passwords do not match'

        expect(find_field('givenName').value).to eq('Damir')
        expect(find_field('surname').value).to eq('Svrtan')
        expect(find_field('middleName').value).to eq('')
        expect(find_field('phoneNumber').value).to eq('0931323232223')
        expect(find_field('password').value).to eq('')
        expect(find_field('confirmPassword').value).to eq('')
      end
    end

    def delete_test_account
      Stormpath::Rails::Client.application.accounts.search(email: 'damir.svrtan@infinum-test.co').first.delete
    end

    describe 'correct submission' do
      after { delete_test_account }

      it 'creates an account' do
        visit 'register'

        fill_in 'givenName', with: 'Damir'
        fill_in 'surname', with: 'Svrtan'
        fill_in 'email', with: 'damir.svrtan@infinum-test.co'
        fill_in 'phoneNumber', with: '0931323232223'
        fill_in 'password', with: 'pa$$W0Rd'
        fill_in 'confirmPassword', with: 'pa$$W0Rd'

        click_button 'Create Account'

        expect(page).to have_content 'Your Account Has Been Created. You may now login'
        expect(current_path).to eq('/login')
      end

      describe 'when autologin is enabled' do
        before do
          allow(web_config.register).to receive(:auto_login).and_return(true)
        end

        it 'creates an account and redirect to root page' do
          visit 'register'

          fill_in 'givenName', with: 'Damir'
          fill_in 'surname', with: 'Svrtan'
          fill_in 'email', with: 'damir.svrtan@infinum-test.co'
          fill_in 'phoneNumber', with: '0931323232223'
          fill_in 'password', with: 'pa$$W0Rd'
          fill_in 'confirmPassword', with: 'pa$$W0Rd'

          click_button 'Create Account'
          expect(page).to have_current_path('/')
        end
      end

      describe 'when account is UNVERIFIED' do
        before do
          allow_any_instance_of(Stormpath::Rails::RegistrationForm).to receive(:account).and_return(
            Stormpath::Resource::Account.new(
              status: 'UNVERIFIED',
              email: 'damir.svrtan@infinum-test.co',
              password: 'pa$$W0Rd',
              surname: 'Svrtan',
              given_name: 'Damir'
            )
          )
        end

        it 'creates an account and redirects to login with status UNVERIFIED' do
          visit 'register'

          fill_in 'givenName', with: 'Damir'
          fill_in 'surname', with: 'Svrtan'
          fill_in 'email', with: 'damir.svrtan@infinum-test.co'
          fill_in 'phoneNumber', with: '0931323232223'
          fill_in 'password', with: 'pa$$W0Rd'
          fill_in 'confirmPassword', with: 'pa$$W0Rd'

          click_button 'Create Account'

          expect(page).to have_content "Your account verification email has been sent! Before you can log into your account, you need to activate your account by clicking the link we sent to your inbox. Didn't get the email?"
          expect(page).to have_current_path('/login?status=unverified')
        end
      end
    end
  end
end
