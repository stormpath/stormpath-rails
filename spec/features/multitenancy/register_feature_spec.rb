require 'spec_helper'

describe 'the multitenant register feature', type: :feature, vcr: true do
  let(:application) { test_client.applications.create(attributes_for(:application)) }
  let(:new_controller) { Stormpath::Rails::Register::NewController }
  let(:create_controller) { Stormpath::Rails::Register::CreateController }
  let(:new_login_controller) { Stormpath::Rails::Login::NewController }
  let(:config) { Stormpath::Rails::Configuration }
  let(:request) do
    OpenStruct.new(original_url: "http://#{subdomain}.#{domain}/login",
                   scheme: 'http',
                   host: "#{subdomain}.#{domain}",
                   domain: domain,
                   subdomain: subdomain,
                   subdomains: subdomains,
                   path: '/register')
  end
  let(:register_config) { configuration.web.register }
  let(:multitenancy_config) { configuration.web.multi_tenancy }
  let(:directory) { test_client.directories.create(attributes_for(:directory)) }
  let(:organization) do
    test_client.organizations.create(attributes_for(:organization, name_key: name_key))
  end
  let(:multi_account_attrs) { attributes_for(:account) }
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
  end

  after do
    organization.delete
    directory.delete
    application.delete
  end

  describe 'GET /register' do
    describe 'when subdomain present' do
      let(:subdomain) { random_name }

      describe 'and organization matches subdomain' do
        let(:name_key) { subdomain }

        it 'has proper labels on register page' do
          visit 'register'
          expect(page).to have_css('label', text: 'Email')
          expect(page).to have_css('label', text: 'Password')
        end
      end

      describe "and organization doesn't match subdomain" do
        let(:name_key) { random_name }

        it 'should redirect to parent domain' do
          allow_any_instance_of(new_controller).to receive(:organization_unresolved?).and_return(false)
          visit 'register'
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
        visit 'register'
        expect(page).to have_css('label', text: 'Enter your organization name to continue')
      end
    end
  end

  describe 'POST /register' do
    let(:name) { multi_account_attrs[:given_name] }
    let(:surname) { multi_account_attrs[:surname] }
    let(:email) { multi_account_attrs[:email] }
    let(:phone) { multi_account_attrs[:phone_number] }
    let(:password) { multi_account_attrs[:password] }

    describe 'when subdomain present' do
      let(:subdomain) { random_name }

      describe 'and organization matches subdomain' do
        let(:name_key) { subdomain }

        it 'should successfully register and redirect to login page' do
          allow_any_instance_of(new_login_controller).to receive(:organization_unresolved?).and_return(false)
          allow_any_instance_of(new_login_controller).to receive(:current_organization).and_return(organization)
          visit 'register'
          fill_in 'givenName', with: name
          fill_in 'surname', with: surname
          fill_in 'email', with: email
          fill_in 'password', with: password

          click_button 'Create Account'
          expect(page).to have_content 'Log in'
        end
      end

      describe "and organization doesn't match subdomain" do
        let(:name_key) { random_name }
        before do
          allow_any_instance_of(new_controller).to receive(:organization_unresolved?).and_return(false)
        end

        describe 'submit correct organization name key' do
          it 'should redirect back to register' do
            visit 'register'
            expect(page).to have_css('label', text: 'Enter your organization name to continue')

            fill_in 'Enter your organization name to continue', with: name_key
            allow_any_instance_of(new_controller).to receive(:current_organization).and_return(organization)
            click_button 'Submit'
            expect(page).to have_css('label', text: 'Email')
            expect(page).to have_css('label', text: 'Password')
          end
        end

        describe 'submit incorrect organization name key' do
          it 'should show warning' do
            visit 'register'
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
        it 'should redirect back to register' do
          visit 'register'
          expect(page).to have_css('label', text: 'Enter your organization name to continue')

          fill_in 'Enter your organization name to continue', with: name_key
          allow_any_instance_of(new_controller).to receive(:current_organization).and_return(organization)
          click_button 'Submit'
          expect(page).to have_css('label', text: 'Email')
          expect(page).to have_css('label', text: 'Password')
          expect(page.body).not_to include('First Name is required.')
        end
      end

      describe 'submit incorrect organization name key' do
        it 'should show warning' do
          visit 'register'
          expect(page).to have_css('label', text: 'Enter your organization name to continue')

          fill_in 'Enter your organization name to continue', with: 'incorrect-name-key'
          click_button 'Submit'

          expect(page).to have_content 'Organization could not be found'
        end
      end
    end
  end
end
