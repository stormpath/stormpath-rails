require 'spec_helper'

describe 'the multitenant forgot password feature', type: :feature, vcr: true do
  let(:application) { test_client.applications.create(attributes_for(:application)) }
  let(:new_controller) { Stormpath::Rails::ForgotPassword::NewController }
  let(:login_controller) { Stormpath::Rails::Login::NewController }
  let(:create_controller) { Stormpath::Rails::ForgotPassword::CreateController }
  let(:config) { Stormpath::Rails::Configuration }
  let(:request) do
    OpenStruct.new(original_url: "http://#{subdomain}.#{domain}/forgot",
                   scheme: 'http',
                   host: "#{subdomain}.#{domain}",
                   domain: domain,
                   subdomain: subdomain,
                   subdomains: subdomains,
                   path: '/forgot')
  end
  let(:forgot_password_config) { configuration.web.forgot_password }
  let(:multitenancy_config) { configuration.web.multi_tenancy }
  let(:directory) { test_client.directories.create(attributes_for(:directory)) }
  let(:organization) do
    test_client.organizations.create(attributes_for(:organization, name_key: name_key))
  end
  let(:account_attrs) { attributes_for(:account) }
  let(:account) { organization.accounts.create(account_attrs) }
  let(:domain) { 'stormpath.dev' }
  let(:subdomains) { [subdomain] }

  before do
    allow(multitenancy_config).to receive(:enabled).and_return(true)
    allow(multitenancy_config).to receive(:strategy).and_return('subdomain')
    allow(configuration.web).to receive(:domain_name).and_return('stormpath.dev')
    map_account_store(application, directory, 0, true, false)
    map_account_store(application, organization, 11, false, false)
    map_organization_store(directory, organization, true)
    allow_any_instance_of(config).to receive(:application).and_return(application)
    allow_any_instance_of(new_controller).to receive(:req).and_return(request)
    allow_any_instance_of(create_controller).to receive(:req).and_return(request)
    allow_any_instance_of(login_controller).to receive(:req).and_return(request)
    account
  end

  after do
    organization.delete
    directory.delete
    application.delete
  end

  describe 'GET /forgot' do
    describe 'when subdomain present' do
      let(:subdomain) { random_name }

      describe 'and organization matches subdomain' do
        let(:name_key) { subdomain }

        it 'has proper labels on forgot page' do
          visit 'forgot'
          expect(page).to have_css('label', text: 'Email')
        end
      end

      describe "and organization doesn't match subdomain" do
        let(:name_key) { random_name }

        it 'should redirect to parent domain' do
          allow_any_instance_of(new_controller).to receive(:organization_unresolved?).and_return(false)
          visit 'forgot'
          expect(page).to have_css('label', text: 'Enter your organization name to continue')
        end
      end
    end

    describe 'when subdomain not present' do
      let(:subdomain) { '' }
      let(:subdomains) { [] }
      let(:name_key) { random_name }

      it 'should show the organization name key field' do
        allow_any_instance_of(new_controller).to receive(:organization_unresolved?).and_return(false)
        visit 'forgot'
        expect(page).to have_css('label', text: 'Enter your organization name to continue')
      end
    end
  end

  describe 'POST /forgot' do
    describe 'when subdomain present' do
      let(:subdomain) { random_name }

      describe 'and organization matches subdomain' do
        let(:name_key) { subdomain }

        it 'should redirect to login page' do
          visit 'forgot'
          fill_in 'Email', with: account.email
          click_button 'Submit'
          expect(page).to have_current_path('/login?status=forgot')
          expect(page).to have_content 'Password Reset Requested. If an account exists for the email provided, you will receive an email shortly.'
        end
      end

      describe "and organization doesn't match subdomain" do
        let(:name_key) { random_name }
        before do
          allow_any_instance_of(new_controller).to receive(:organization_unresolved?).and_return(false)
        end

        describe 'submit correct organization name key' do
          it 'should redirect back to forgot' do
            visit 'forgot'
            expect(page).to have_css('label', text: 'Enter your organization name to continue')

            fill_in 'Enter your organization name to continue', with: name_key
            allow_any_instance_of(new_controller).to receive(:current_organization).and_return(organization)
            click_button 'Submit'
            expect(page).to have_css('label', text: 'Email')
          end
        end

        describe 'submit incorrect organization name key' do
          it 'should show warning' do
            visit 'forgot'
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
      let(:subdomains) { [] }
      let(:name_key) { random_name }
      before do
        allow_any_instance_of(new_controller).to receive(:organization_unresolved?).and_return(false)
      end

      describe 'submit correct organization name key' do
        it 'should redirect back to forgot' do
          visit 'forgot'
          expect(page).to have_css('label', text: 'Enter your organization name to continue')

          fill_in 'Enter your organization name to continue', with: name_key
          allow_any_instance_of(new_controller).to receive(:current_organization).and_return(organization)
          click_button 'Submit'
          expect(page).to have_css('label', text: 'Email')
        end
      end

      describe 'submit incorrect organization name key' do
        it 'should show warning' do
          visit 'forgot'
          expect(page).to have_css('label', text: 'Enter your organization name to continue')

          fill_in 'Enter your organization name to continue', with: 'incorrect-name-key'
          click_button 'Submit'

          expect(page).to have_content 'Organization could not be found'
        end
      end
    end
  end
end
