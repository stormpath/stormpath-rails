require 'spec_helper'

describe 'the signup process', type: :feature, vcr: true do
  let(:register_config) { Stormpath::Rails.config.web.register }

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

        expect(find_field('givenName').value).to have_content 'Damir'
        expect(find_field('surname').value).to have_content 'Svrtan'
        expect(find_field('middleName').value).to have_content ''
        expect(find_field('phoneNumber').value).to have_content '0931323232223'
        expect(find_field('password').value).to have_content ''
        expect(find_field('confirmPassword').value).to have_content ''
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
    end
  end
end
