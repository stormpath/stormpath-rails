require 'spec_helper'

describe Stormpath::Rails::SocialAuthorization, vcr: true, type: :service do
  let(:application) { test_client.applications.create(attributes_for(:application)) }
  let(:default_directory) { test_client.directories.create(attributes_for(:directory)) }
  let(:facebook_directory) { create_provider_directory(:facebook) }
  let(:linkedin_directory) { create_provider_directory(:linkedin) }
  let(:github_directory) { create_provider_directory(:github) }
  let!(:google_directory) { create_provider_directory(:google) }
  let(:social_authorization) { Stormpath::Rails::SocialAuthorization.build_login_urls(request) }
  let(:request) { OpenStruct.new(base_url: 'localhost:3000') }

  before do
    map_account_store(application, default_directory, 0, true, true)
    map_account_store(application, facebook_directory, 1, false, false)
    map_account_store(application, linkedin_directory, 2, false, false)
    map_account_store(application, github_directory, 3, false, false)
    allow_any_instance_of(Stormpath::Rails::SocialAuthorization).to receive(:application).and_return(application)
  end

  after do
    default_directory.delete
    facebook_directory.delete
    linkedin_directory.delete
    github_directory.delete
    google_directory.delete
    application.delete
  end

  describe 'application with 3 mapped social account stores' do
    it 'should have the corresponding provider login links' do
      expect(social_authorization.facebook_login_url).to be_present
      expect(social_authorization.linkedin_login_url).to be_present
      expect(social_authorization.github_login_url).to be_present
    end
  end

  describe 'application with 1 unmapped social account store' do
    it 'should raise error if trying to get login url' do
      expect { social_authorization.google_login_url }.to raise_error(NoMethodError)
    end
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
