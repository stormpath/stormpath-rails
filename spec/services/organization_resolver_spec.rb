require 'spec_helper'

describe Stormpath::Rails::OrganizationResolver, vcr: true do
  let(:application) { test_client.applications.create(attributes_for(:application)) }
  let(:organization) { test_client.organizations.create(attributes_for(:organization)) }
  let(:resolver) do
    Stormpath::Rails::OrganizationResolver.new(request, org_name_key)
  end
  let(:config) { Stormpath::Rails::Configuration }
  let(:request) { OpenStruct.new(subdomain: subdomain) }
  let(:org_name_key) { nil }

  before do
    allow_any_instance_of(config).to receive(:application).and_return(application)
    map_account_store(application, organization, 0, true, false)
  end
  after do
    organization.delete
    application.delete
  end

  describe 'existing organization and mapped to application' do
    context 'from host' do
      let(:subdomain) { organization.name_key }

      it 'should return the organization' do
        expect(resolver.organization).to eq organization
      end
    end

    context 'from body' do
      let(:subdomain) { 'bad-org-name-key' }
      let(:org_name_key) { organization.name_key }

      it 'should return the organization' do
        expect(resolver.organization).to eq organization
      end
    end
  end

  describe 'existing organization but not mapped to application' do
    let(:unmapped_organization) do
      test_client.organizations.create(attributes_for(:organization))
    end
    let(:subdomain) { unmapped_organization.name_key }

    after { unmapped_organization.delete }

    it 'shoult raise error' do
      expect do
        resolver.organization
      end.to raise_error(Stormpath::Rails::OrganizationResolver::Error)
    end
  end

  describe 'non-existing organization' do
    let(:subdomain) { 'non-existing-org' }

    it 'shoult raise error' do
      expect do
        resolver.organization
      end.to raise_error(Stormpath::Rails::OrganizationResolver::Error)
    end
  end

  describe 'application with no account store mappings' do
    let(:subdomain) { 'non-existing-org' }
    let!(:app2) { test_client.applications.create(attributes_for(:application)) }
    after { app2.delete }

    it 'shoult raise error' do
      allow(resolver).to receive(:application).and_return(app2)
      expect do
        resolver.organization
      end.to raise_error(Stormpath::Rails::OrganizationResolver::Error)
    end
  end
end
