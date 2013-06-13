require "spec_helper"

describe Stormpath::Rails::Client, :vcr do

  describe ".client" do
    context "given a valid Stormpath API key ID and secret" do
      let(:client) do
        Stormpath::Rails::Client.client
      end

      it "should instantiate a Stormpath Client" do
        expect(client).to be
        expect(client).to be_kind_of Stormpath::Client
      end

      it "should instantiate a Stormpath Tenant" do
        expect(client.tenant).to be
        expect(client.tenant).to be_kind_of Stormpath::Resource::Tenant
      end
    end

    context 'given a composite url' do
      let(:composite_url) { 'http://ASDF1234:ZXCV5678@example.com/foo/bar' }
      let(:application) { double 'application' }
      let(:loaded_client) { double 'client' }
      let(:returned_client) { Stormpath::Rails::Client.client }

      before do
        ENV['STORMPATH_URL'] = composite_url
      end

      it 'loads the client from the application' do
        Stormpath::Resource::Application
          .should_receive(:load)
          .with(composite_url)
          .and_return(application)

        application
          .should_receive(:client)
          .and_return(loaded_client)

        expect(returned_client).to be
        expect(returned_client).to eq(loaded_client)
      end

      after do
        ENV['STORMPATH_URL'] = nil
      end
    end
  end

  describe ".create_account!" do
    context "given a hash of account attributes" do
      let(:attributes) do
        {
          'email' => 'test+foo+bar@example.com',
          'given_name' => 'bazzy',
          'surname' => 'foo',
          'password' => 'P@66w0rd!',
          'username' => 'testfoobar'
        }
      end

      let(:account) do
        Stormpath::Rails::Client.create_account! attributes
      end

      it "should create an account" do
        expect(account).to be
        expect(account).to be_kind_of Stormpath::Resource::Account
        expect(account.given_name).to eq(attributes['given_name'])
      end

      after do
        account.delete
      end
    end
  end

  describe ".authenticate_account" do
    context "given a valid username and password" do
      let(:username) { 'testfoobar' }
      let(:password) { 'Succ3ss!' }

      let!(:test_account) do
        obtain_test_account(
          'username' => 'testfoobar',
          'password' => 'Succ3ss!'
        )
      end

      let(:authenticated_account) do
        Stormpath::Rails::Client.authenticate_account(
          username, password
        )
      end

      it "authenticates the account" do
        expect(authenticated_account).to be
        expect(authenticated_account).to be_kind_of Stormpath::Resource::Account
        expect(authenticated_account.username).to eq(username)
      end

      after do
        authenticated_account.delete
      end
    end
  end

  describe ".update_account!" do
    context "given a valid account" do
      let(:new_name) { "Bartholomew" }

      let(:created_account) do
        obtain_test_account 'given_name' => 'Foo'
      end

      let(:reloaded_account) do
        found_account = nil

        Stormpath::Rails::Client.all_accounts.each do |a|
          found_account = a unless a.href != created_account.href or !found_account.nil?
        end

        found_account
      end

      before do
        Stormpath::Rails::Client.update_account!(
          created_account.href, 'given_name' => new_name
        )
      end

      it "updates the account" do
        expect(reloaded_account).to be
        expect(reloaded_account.given_name).to eq(new_name)
      end

      after do
        created_account.delete
      end
    end
  end

  describe ".find_account" do
    context "given a valid account" do
      let(:created_account) { obtain_test_account }
      let(:returned_account) do
        Stormpath::Rails::Client.find_account(
          created_account.href
        )
      end

      it "returns the account" do
        expect(returned_account).to be
        expect(returned_account).to be_kind_of Stormpath::Resource::Account
        expect(returned_account.href).to eq(created_account.href)
      end

      after do
        created_account.delete
      end
    end
  end

  describe ".send_password_reset_email" do
    context "given a valid account" do
      let(:created_account) { obtain_test_account }
      let(:returned_account) do
        Stormpath::Rails::Client.send_password_reset_email(
          created_account.email
        )
      end

      it "sends the reset email" do
        expect(returned_account).to be
        expect(returned_account).to be_kind_of Stormpath::Resource::Account
        expect(returned_account.href).to eq(created_account.href)
      end

      after do
        created_account.delete
      end
    end
  end

  describe '.verify_password_reset_token' do
    let(:password_reset_token) { 'ASDF1234' }
    let(:application) { double('application') }

    it 'delegates to the application instance' do
      Stormpath::Rails::Client
        .should_receive(:application)
        .and_return application

      application
        .should_receive(:verify_password_reset_token)
        .with(password_reset_token)

      Stormpath::Rails::Client.verify_password_reset_token(
        password_reset_token
      )
    end
  end

  describe '.verify_account_email' do
    let(:email_verification_token) { 'ASDF1234' }
    let(:accounts) { double('accounts') }

    it 'delegates to the application instance' do
      Stormpath::Rails::Client
        .stub_chain(:client, :accounts)
        .and_return(accounts)

      accounts
        .should_receive(:verify_email_token)
        .with email_verification_token

      Stormpath::Rails::Client.verify_account_email email_verification_token
    end
  end
end
