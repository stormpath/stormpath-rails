require 'spec_helper'

describe Stormpath::Rails::OrganizationResolver, vcr: true do
  let(:organization) { test_client.organizations.create(FactoryGirl.attributes_for(:organization)) }
  let(:resolver) { Stormpath::Rails::OrganizationResolver.new(request) }
  let(:request) do
    OpenStruct.new(subdomain: subdomain)
  end

  after { organization.delete }

  describe 'existing organization' do
    let(:subdomain) { organization.name_key }

    it 'should return the organization from subdomain' do
      expect(resolver.organization).to eq organization
    end
  end

  describe 'non-existing organization' do
    let(:subdomain) { 'non-existing-org' }

    it 'should return nil' do
      expect(resolver.organization).to be_nil
    end
  end
end
