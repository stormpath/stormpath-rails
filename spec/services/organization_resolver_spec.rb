require 'spec_helper'

describe Stormpath::Rails::OrganizationResolver, vcr: true do
  let(:application) { test_application }
  let(:organization) { test_client.organizations.create(attributes_for(:organization)) }
  let(:resolver) { Stormpath::Rails::OrganizationResolver.new(request) }
  let(:request) { OpenStruct.new(subdomain: subdomain) }

  before { map_account_store(application, organization, 10, false, false) }
  after { organization.delete }

  describe 'existing organization and mapped to application' do
    let(:subdomain) { organization.name_key }

    it 'should return the organization from subdomain' do
      expect(resolver.organization).to eq organization
    end
  end

  describe 'existing organization but not mapped to application' do
    let(:unmapped_organization) do
      test_client.organizations.create(attributes_for(:organization))
    end
    let(:subdomain) { unmapped_organization.name_key }

    after { unmapped_organization.delete }

    it 'shoult return nil' do
      expect(resolver.organization).to be_nil
    end
  end

  describe 'non-existing organization' do
    let(:subdomain) { 'non-existing-org' }

    it 'should return nil' do
      expect(resolver.organization).to be_nil
    end
  end

  describe 'application with no account store mappings' do
    let(:subdomain) { 'non-existing-org' }
    let!(:app2) { test_client.applications.create(attributes_for(:application)) }
    after { app2.delete }

    it 'should return nil' do
      allow(resolver).to receive(:application).and_return(app2)
      expect(resolver.organization).to be_nil
    end
  end
end
