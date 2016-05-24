require 'spec_helper'

describe Stormpath::Rails::LoginNewSerializer, vcr: true do
  let(:serializer) { Stormpath::Rails::LoginNewSerializer }

  let(:serialized_json) { serializer.to_h }

  describe '#to_h' do
    it 'should serialize the default properly' do
      expect(serialized_json[:form]).to eq(
        {:fields =>
          [{:label => "Username or Email",
            :placeholder => "Username or Email",
            :required => true,
            :type => "text",
            :name => :login},
           {:label => "Password",
            :placeholder => "Password",
            :required => true,
            :type => "password",
            :name => :password}]}
      )
    end

    it 'should order differently if field order changed' do
      allow(Stormpath::Rails.config.web.login.form).to receive(:field_order).and_return(['password', 'login'])
      expect(serialized_json[:form]).to eq(
        {:fields =>
          [{:label => "Password",
            :placeholder => "Password",
            :required => true,
            :type => "password",
            :name => :password},
           {:label => "Username or Email",
            :placeholder => "Username or Email",
            :required => true,
            :type => "text",
            :name => :login}]}
      )
    end

    it 'should show all even if missing from field order' do
      allow(Stormpath::Rails.config.web.login.form).to receive(:field_order).and_return(['password'])
      expect(serialized_json[:form]).to eq(
        {:fields =>
          [{:label => "Password",
            :placeholder => "Password",
            :required => true,
            :type => "password",
            :name => :password},
           {:label => "Username or Email",
            :placeholder => "Username or Email",
            :required => true,
            :type => "text",
            :name => :login}]}
      )
    end

    it 'should show only login field if password is disabled' do
      Stormpath::Rails.config.web.login.form.fields.password.enabled = false

      expect(serialized_json[:form]).to eq(
        {:fields =>
          [{:label => "Username or Email",
            :placeholder => "Username or Email",
            :required => true,
            :type => "text",
            :name => :login}]}
      )

      Stormpath::Rails.config.web.login.form.fields.password.enabled = true
    end

    it 'should show only login field if password is not visible' do
      Stormpath::Rails.config.web.login.form.fields.password.visible = false

      expect(serialized_json[:form]).to eq(
        {:fields =>
          [{:label => "Username or Email",
            :placeholder => "Username or Email",
            :required => true,
            :type => "text",
            :name => :login}]}
      )

      Stormpath::Rails.config.web.login.form.fields.password.visible = true
    end
  end
end
