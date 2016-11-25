require 'spec_helper'

describe 'the multitenant login feature', type: :feature, vcr: true do
  let(:new_controller) { Stormpath::Rails::Login::NewController }
  let(:create_controller) { Stormpath::Rails::Login::CreateController }
  let(:request) do
    OpenStruct.new(original_url: "http://#{subdomain}.#{domain}/login",
                   scheme: 'http',
                   host: "#{subdomain}.#{domain}",
                   domain: domain,
                   subdomain: subdomain,
                   path: '/login')
  end
  let(:login_config) { configuration.web.login }
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
    map_account_store(test_application, directory, 10, false, false)
    map_account_store(test_application, organization, 11, false, false)
    map_organization_store(directory, organization, true)
    allow_any_instance_of(new_controller).to receive(:req).and_return(request)
    allow_any_instance_of(create_controller).to receive(:req).and_return(request)
  end

  after do
    organization.delete
    directory.delete
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
          allow_any_instance_of(new_controller).to receive(:should_resolve_organization?).and_return(false)
          visit 'login'
          expect(page).to have_css('label', text: 'Organization Name Key')
        end
      end
    end

    describe 'when subdomain not present' do
      let(:subdomain) { '' }
      let(:name_key) { random_name }

      it 'should show the organization name key field' do
        allow_any_instance_of(new_controller).to receive(:should_resolve_organization?).and_return(false)
        visit 'login'
        expect(page).to have_css('label', text: 'Organization Name Key')
      end
    end
  end

  describe 'POST /login' do
    describe 'when subdomain present' do
      let(:subdomain) { random_name }

      describe 'and organization matches subdomain' do
        let(:name_key) { subdomain }

        let!(:account) { organization.accounts.create(multi_account_attrs) }

        it 'should successfully log in and redirect to root page' do
          visit 'login'
          fill_in 'Username or Email', with: account.email
          fill_in 'Password', with: 'Password1337'
          click_button 'Log in'
          expect(page).to have_content 'Root page'
        end
      end

      describe "and organization doesn't match subdomain" do
        let(:name_key) { random_name }
        before do
          allow_any_instance_of(new_controller).to receive(:should_resolve_organization?).and_return(false)
        end

        describe 'submit correct organization name key' do
          it 'should redirect back to login' do
            visit 'login'
            expect(page).to have_css('label', text: 'Organization Name Key')

            fill_in 'Organization Name Key', with: name_key
            allow_any_instance_of(new_controller).to receive(:current_organization).and_return(organization)
            click_button 'Go to login'
            expect(page).to have_css('label', text: 'Username or Email')
            expect(page).to have_css('label', text: 'Password')
          end
        end

        describe 'submit incorrect organization name key' do
          it 'should show warning' do
            visit 'login'
            expect(page).to have_css('label', text: 'Organization Name Key')

            fill_in 'Organization Name Key', with: 'incorrect-name-key'
            click_button 'Go to login'

            expect(page).to have_content 'Organization is not found'
          end
        end
      end
    end

    describe 'when subdomain missing' do
      let(:subdomain) { '' }
      let(:name_key) { random_name }
      before do
        allow_any_instance_of(new_controller).to receive(:should_resolve_organization?).and_return(false)
      end

      describe 'submit correct organization name key' do
        it 'should redirect back to login' do
          visit 'login'
          expect(page).to have_css('label', text: 'Organization Name Key')

          fill_in 'Organization Name Key', with: name_key
          allow_any_instance_of(new_controller).to receive(:current_organization).and_return(organization)
          click_button 'Go to login'
          expect(page).to have_css('label', text: 'Username or Email')
          expect(page).to have_css('label', text: 'Password')
        end
      end

      describe 'submit incorrect organization name key' do
        it 'should show warning' do
          visit 'login'
          expect(page).to have_css('label', text: 'Organization Name Key')

          fill_in 'Organization Name Key', with: 'incorrect-name-key'
          click_button 'Go to login'

          expect(page).to have_content 'Organization is not found'
        end
      end
    end
  end
end
