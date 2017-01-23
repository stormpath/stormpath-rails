require 'spec_helper'

describe 'SocialDirectories', type: :service, vcr: true do
  let(:application) { test_client.applications.create(attributes_for(:application)) }
  let(:default_directory) { test_client.directories.create(attributes_for(:directory)) }
  let(:facebook_directory) { create_provider_directory(:facebook) }
  let(:organization) { test_client.organizations.create(attributes_for(:organization)) }
  let(:social_directories) { Stormpath::Rails::SocialDirectories.for(application) }

  before do
    map_account_store(application, default_directory, 0, true, true)
    map_account_store(application, facebook_directory, 1, false, false)
    map_account_store(application, organization, 2, false, false)
  end

  after do
    default_directory.delete
    facebook_directory.delete
    application.delete
  end

  it 'should return the facebook directory' do
    expect(social_directories).to include(facebook_directory)
  end

  it 'should not return the default directory' do
    expect(social_directories).not_to include(default_directory)
  end

  it 'should not return any organizations' do
    expect(social_directories).not_to include(organization)
  end

  def create_provider_directory(provider)
    test_client.directories.create(attributes_for(:directory, provider: {
                                                    provider_id: provider,
                                                    client_id: 'qwertyuioasdfghjkl',
                                                    client_secret: 'qwertyuioasdfghjkl',
                                                    redirect_uri: 'http://localhost:3000/callback'
                                                  }))
  end
end
