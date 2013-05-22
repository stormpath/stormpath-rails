require "spec_helper"

describe Stormpath::Rails::Client, :vcr do

  describe ".client" do
    context "given a valid Stormpath API key ID and secret" do
      let(:client) do
        Stormpath::Rails::Client.client
      end

      it "should instantiate a Stormpath Client" do
        client.should be
        client.should be_kind_of Stormpath::Client
        client.tenant.should be
        client.tenant.should be_kind_of Stormpath::Resource::Tenant
      end
    end
  end

  describe ".create_account!" do
    context "given a hash of account attributes" do
      let(:attributes) do
        o = {
          "email" => "test+foo+bar@example.com",
          "given_name" => "bazzy",
          "surname" => "foo",
          "password" => "P@66w0rd!",
          "username" => 'testfoobar'
        }
      end

      let(:account) do
        Stormpath::Rails::Client.create_account!(attributes)
      end

      it "should create an account" do
        account.should be
        account.should be_kind_of Stormpath::Resource::Account
        account.given_name.should == attributes["given_name"]
      end

      after do
        account.delete
      end
    end
  end

  describe ".authenticate_account" do
    context "given a valid username and password" do
      let(:username) do
        "testfoobar"
      end

      let(:password) do
        'Succ3ss!'
      end

      let(:authenticated_account) do
        Stormpath::Rails::Client.authenticate_account(username, password)
      end

      before do
        obtain_test_account({
          "username" => username,
          "password" => password
        })
      end

      it "authenticates the account" do
        authenticated_account.should be
        authenticated_account.should be_kind_of Stormpath::Resource::Account
        authenticated_account.username.should == username
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
        obtain_test_account({
          "given_name" => "Foo"
        })
      end

      let(:reloaded_account) do
        found_account = nil

        Stormpath::Rails::Client.all_accounts.each do |a|
          found_account = a unless a.href != created_account.href or !found_account.nil?
        end

        found_account
      end

      before do
        Stormpath::Rails::Client.update_account!(created_account.href, {
          "given_name" => new_name
        })
      end

      it "updates the account" do
        reloaded_account.should be
        reloaded_account.given_name.should == new_name
      end

      after do
        created_account.delete
      end
    end
  end

  describe ".find_account" do
    context "given a valid account" do
      let(:created_account) do
        obtain_test_account
      end

      let(:returned_account) do
        Stormpath::Rails::Client.find_account(created_account.href)
      end

      it "returns the account" do
        returned_account.should be
        returned_account.should be_kind_of Stormpath::Resource::Account
        returned_account.href.should == created_account.href
      end

      after do
        created_account.delete
      end
    end
  end

  describe ".send_password_reset_email" do
    context "given a valid account" do
      let(:created_account) do
        obtain_test_account
      end

      let(:returned_account) do
        Stormpath::Rails::Client.send_password_reset_email(created_account.email)
      end

      it "sends the reset email" do
        returned_account.should be
        returned_account.should be_kind_of Stormpath::Resource::Account
        returned_account.href.should == created_account.href
      end

      after do
        created_account.delete
      end
    end
  end
end
