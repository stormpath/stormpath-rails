require 'spec_helper'

describe 'the multitenant login feature', type: :feature, vcr: true do
  let(:application) { test_client.applications.create(attributes_for(:application)) }
  let(:new_controller) { Stormpath::Rails::Login::NewController }
  let(:create_controller) { Stormpath::Rails::Login::CreateController }
  let(:config) { Stormpath::Rails::Configuration }
  let(:request) do
    OpenStruct.new(original_url: "http://#{subdomain}.#{domain}/login",
                   scheme: 'http',
                   host: "#{subdomain}.#{domain}",
                   domain: domain,
                   subdomain: subdomain,
                   path: '/login')
  end
  let(:multitenancy_config) { configuration.web.multi_tenancy }
  let(:directory) { test_client.directories.create(attributes_for(:directory)) }
  let(:organization) do
    test_client.organizations.create(attributes_for(:organization, name_key: name_key))
  end
  let(:multi_account_attrs) { attributes_for(:account) }
  let(:domain) { 'stormpath.dev' }

  before do
    allow(multitenancy_config).to receive(:enabled).and_return(true)
    allow(multitenancy_config).to receive(:strategy).and_return('subdomain')
    allow(configuration.web).to receive(:domain_name).and_return('stormpath.dev')
    map_account_store(application, directory, 10, true, false)
    map_account_store(application, organization, 11, false, false)
    map_organization_store(directory, organization, true)
    allow_any_instance_of(config).to receive(:application).and_return(application)
    allow_any_instance_of(new_controller).to receive(:req).and_return(request)
    allow_any_instance_of(create_controller).to receive(:req).and_return(request)
  end

  after do
    organization.delete
    directory.delete
    application.delete
  end

  describe 'GET /login' do
    describe 'when subdomain present' do
      let(:subdomain) { random_name }

      describe 'and organization matches subdomain' do
        let(:name_key) { subdomain }

        it 'has proper labels on login page' do
          visit 'login'
          expect(page).to have_css('label', text: 'Username or Email')
          expect(page).to have_css('label', text: 'Password')
        end
      end

      describe "and organization doesn't match subdomain" do
        let(:name_key) { random_name }

        it 'should redirect to parent domain' do
          allow_any_instance_of(new_controller).to receive(:organization_unresolved?).and_return(false)
          visit 'login'
          expect(page).to have_css('label', text: 'Enter your organization name to continue')
        end
      end
    end

    describe 'when subdomain not present' do
      let(:subdomain) { '' }
      let(:name_key) { random_name }

      it 'should show the organization name key field' do
        allow_any_instance_of(new_controller).to receive(:organization_unresolved?).and_return(false)
        visit 'login'
        expect(page).to have_css('label', text: 'Enter your organization name to continue')
      end
    end
  end

  describe 'POST /login' do
    describe 'when subdomain present' do
      let(:subdomain) { random_name }

      describe 'and organization matches subdomain' do
        let(:name_key) { subdomain }

        let!(:account) { organization.accounts.create(multi_account_attrs) }

        context 'when the account is in the directory and organization' do
          it 'should successfully log in and redirect to root page' do
            visit 'login'
            fill_in 'Username or Email', with: account.email
            fill_in 'Password', with: 'Password1337'
            click_button 'Log in'
            expect(page).to have_content 'Root page'
          end
        end

        context 'when the account is in another directory and organization' do
          let(:another_dir) { test_client.directories.create(attributes_for(:directory)) }
          let(:another_org) { test_client.organizations.create(attributes_for(:organization)) }
          before do
            map_account_store(application, another_dir, 10, false, false)
            map_account_store(application, another_org, 11, false, false)
            map_organization_store(another_dir, another_org, true)
          end
          let!(:another_account) { another_org.accounts.create(attributes_for(:account)) }
          after do
            another_org.delete
            another_dir.delete
          end

          it 'should raise error' do
            visit 'login'
            fill_in 'Username or Email', with: another_account.email
            fill_in 'Password', with: 'Password1337'
            click_button 'Log in'
            expect(page).to have_content 'Invalid username or password.'
          end
        end

        context 'when the account is in the same directory but different organization' do
          let(:org3) { test_client.organizations.create(attributes_for(:organization)) }
          before do
            map_account_store(application, org3, 13, false, false)
            map_organization_store(directory, org3, true)
          end
          let!(:account3) { org3.accounts.create(attributes_for(:account)) }
          after { org3.delete }

          it 'should successfully log in and redirect to root page' do
            visit 'login'
            fill_in 'Username or Email', with: account3.email
            fill_in 'Password', with: 'Password1337'
            click_button 'Log in'
            expect(page).to have_content 'Root page'
          end
        end
      end

      describe "and organization doesn't match subdomain" do
        let(:name_key) { random_name }
        before do
          allow_any_instance_of(new_controller).to receive(:organization_unresolved?).and_return(false)
        end

        describe 'submit correct organization name key' do
          it 'should redirect back to login' do
            visit 'login'
            expect(page).to have_css('label', text: 'Enter your organization name to continue')

            fill_in 'Enter your organization name to continue', with: name_key
            allow_any_instance_of(new_controller).to receive(:current_organization).and_return(organization)
            click_button 'Submit'
            expect(page).to have_css('label', text: 'Username or Email')
            expect(page).to have_css('label', text: 'Password')
          end
        end

        describe 'submit incorrect organization name key' do
          it 'should show warning' do
            visit 'login'
            expect(page).to have_css('label', text: 'Enter your organization name to continue')

            fill_in 'Enter your organization name to continue', with: 'incorrect-name-key'
            click_button 'Submit'

            expect(page).to have_content 'Organization could not be found'
          end
        end
      end
    end

    describe 'when subdomain missing' do
      let(:subdomain) { '' }
      let(:name_key) { random_name }
      before do
        allow_any_instance_of(new_controller).to receive(:organization_unresolved?).and_return(false)
      end

      describe 'submit correct organization name key' do
        it 'should redirect back to login' do
          visit 'login'
          expect(page).to have_css('label', text: 'Enter your organization name to continue')

          fill_in 'Enter your organization name to continue', with: name_key
          allow_any_instance_of(new_controller).to receive(:current_organization).and_return(organization)
          click_button 'Submit'
          expect(page).to have_css('label', text: 'Username or Email')
          expect(page).to have_css('label', text: 'Password')
        end
      end

      describe 'submit incorrect organization name key' do
        it 'should show warning' do
          visit 'login'
          expect(page).to have_css('label', text: 'Enter your organization name to continue')

          fill_in 'Enter your organization name to continue', with: 'incorrect-name-key'
          click_button 'Submit'

          expect(page).to have_content 'Organization could not be found'
        end
      end
    end
  end
end
