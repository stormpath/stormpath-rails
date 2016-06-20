require 'spec_helper'

describe Stormpath::Rails::RegistrationForm, vcr: true do
  let(:register_config) { configuration.web.register }

  let(:form) do
    Stormpath::Rails::RegistrationForm.new(params)
  end

  let(:params) do
    {
      givenName: 'Damir',
      email: 'damir.svrtan@gmail.com',
      surname: 'Svrtan',
      password: 'Pa$$W0Rten'
    }
  end

  it 'should be invokeable' do
    expect(form.given_name).to eq('Damir')
    expect(form.email).to eq('damir.svrtan@gmail.com')
    expect(form.surname).to eq('Svrtan')
    expect(form.password).to eq('Pa$$W0Rten')
  end

  it 'should be valid' do
    expect(form.valid?).to be
  end

  describe 'with custom data' do
    before(:each) do
      register_config.form.fields.age = OpenStruct.new(enabled: true, visible: true, label: 'Age', placeholder: 'Age', required: true, type: 'number')
      Stormpath::Rails.send(:remove_const, 'RegistrationForm')
      load('stormpath/rails/registration_form.rb')
    end

    after do
      register_config.form.fields.delete_field(:age)
    end

    let(:params) do
      {
        givenName: 'Damir',
        email: 'damir.svrtan@gmail.com',
        surname: 'Svrtan',
        password: 'Pa$$W0Rten',
        age: 25
      }
    end

    it 'should be invokeable' do
      expect(form.age).to eq(25)
    end

    it 'should be valid' do
      expect(form.valid?).to be
    end

    describe 'with nested customData' do
      let(:params) do
        {
          givenName: 'Damir',
          email: 'damir.svrtan@gmail.com',
          surname: 'Svrtan',
          password: 'Pa$$W0Rten',
          customData: {
            age: 25
          }
        }
      end

      it 'should be invokeable' do
        expect(form.age).to eq(25)
      end

      it 'should be valid' do
        expect(form.valid?).to be
      end
    end
  end

  describe 'with missing data' do
    before(:each) do
      Stormpath::Rails.send(:remove_const, 'RegistrationForm') && load('stormpath/rails/registration_form.rb')
    end

    let(:params) do
      {
        email: 'damir.svrtan@gmail.com',
        surname: 'Svrtan',
        password: 'Pa$$W0Rten'
      }
    end

    it 'should be invalid' do
      expect(form.valid?).not_to be
      expect(form.errors.full_messages.first).to eq('First Name can\'t be blank')
    end
  end
end
