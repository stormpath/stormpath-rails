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
end