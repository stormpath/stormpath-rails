require 'spec_helper'

describe Stormpath::Rails::RegistrationFormFields, vcr: true do
  let(:form_fields) { Stormpath::Rails::RegistrationFormFields }

  let(:register_config) { configuration.web.register }

  describe 'required field names' do
    subject { form_fields.required_field_names }
    it { is_expected.to match_array([:email, :password, :given_name, :surname]) }

    describe 'when surname not required' do
      before { register_config.form.fields.surname.enabled = false }
      after  { register_config.form.fields.surname.enabled = true }

      it { is_expected.to match_array([:email, :password, :given_name]) }
    end

    describe 'when username enabled & required' do
      before { register_config.form.fields.username.enabled = true }
      after  { register_config.form.fields.username.enabled = false }

      it { is_expected.to match_array([:email, :password, :given_name, :surname, :username]) }
    end

    describe 'when custom data age is enabled & required' do
      before do
        register_config.form.fields.age = OpenStruct.new(enabled: true, visible: true, label: 'Age', placeholder: 'Age', required: true, type: 'number')
      end

      after do
        register_config.form.fields.delete_field(:age)
      end

      it { is_expected.to match_array([:email, :password, :given_name, :surname, :age]) }
    end
  end

  describe 'enabled field names' do
    subject { form_fields.enabled_field_names }
    it { is_expected.to match_array([:email, :password, :given_name, :surname]) }

    describe 'when username enabled' do
      before { register_config.form.fields.username.enabled = true }
      after  { register_config.form.fields.username.enabled = false }

      it { is_expected.to match_array([:email, :password, :given_name, :surname, :username]) }
    end
  end

  describe 'custom enabled field names' do
    subject { form_fields.custom_enabled_field_names }
    it { is_expected.to be_empty }

    describe 'when custom data age is enabled' do
      before do
        register_config.form.fields.age = OpenStruct.new(enabled: true, visible: true, label: 'Age', placeholder: 'Age', required: true, type: 'number')
      end

      after do
        register_config.form.fields.delete_field(:age)
      end

      it { is_expected.to match_array([:age]) }
    end
  end

  describe 'predefined enabled field names' do
    subject { form_fields.predefined_enabled_field_names }
    it { is_expected.to match_array([:email, :password, :given_name, :surname]) }

    describe 'when custom data age is enabled' do
      before do
        register_config.form.fields.age = OpenStruct.new(enabled: true, visible: true, label: 'Age', placeholder: 'Age', required: true, type: 'number')
      end

      after do
        register_config.form.fields.delete_field(:age)
      end

      it { is_expected.to match_array([:email, :password, :given_name, :surname]) }
    end
  end
end
