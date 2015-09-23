require 'spec_helper'

describe User do
  it { expect(subject).to validate_presence_of(:given_name) }
  it { expect(subject).to validate_presence_of(:surname) }

  describe "#email" do
    subject { create(:user) }
    it { expect(subject).to have_db_index(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { expect(subject).to validate_presence_of(:email) }
  end

  describe "the password setter on a User" do
    it "sets password to the plain-text password" do
      password = "password"
      subject.send(:password=, password)

      expect(subject.password).to eq password
    end
  end

  describe ".normalize_email" do
    it "downcases the address and strips spaces" do
      email = "Jo hn.Do e @exa mp le.c om"

      expect(User.normalize_email(email)).to eq "john.doe@example.com"
    end
  end

  describe ".find_user" do
    it "finds user by email" do
      user = create(:user)

      expect(User.find_user(user.email.upcase)).to eq(user)
    end
  end
end