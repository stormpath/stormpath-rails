require 'spec_helper'

describe 'the multitenant email verification feature', type: :feature, vcr: true do
  let(:application) { test_client.applications.create(attributes_for(:application)) }
  let(:directory) { test_client.directories.create(attributes_for(:directory)) }
  let(:sptoken) { account.email_verification_token.token }
  let(:show_controller) { Stormpath::Rails::VerifyEmail::ShowController }
  let(:create_controller) { Stormpath::Rails::VerifyEmail::CreateController }
  let(:login_controller) { Stormpath::Rails::Login::NewController }
  let(:config) { Stormpath::Rails::Configuration }
  let(:request) do
    OpenStruct.new(scheme: 'http',
                   host: "#{subdomains.join('.')}.#{domain}",
                   domain: domain,
                   subdomains: subdomains,
                   path: '/verify')
  end
  let(:multitenancy_config) { configuration.web.multi_tenancy }
  let(:organization) do
    test_client.organizations.create(attributes_for(:organization, name_key: name_key))
  end
  let(:account_attrs) { attributes_for(:account) }
  let(:account) { organization.accounts.create(account_attrs) }
  let(:domain) { 'stormpath.dev' }
  let(:subdomains) { [subdomain] }

  before do
    allow_any_instance_of(config).to receive(:application).and_return(application)
    allow(multitenancy_config).to receive(:enabled).and_return(true)
    allow(multitenancy_config).to receive(:strategy).and_return('subdomain')
    allow(configuration.web).to receive(:domain_name).and_return('stormpath.dev')
    enable_email_verification_for(directory)
    map_account_store(application, directory, 0, true, false)
    map_account_store(application, organization, 20, false, false)
    map_organization_store(directory, organization, true)
    enable_email_verification
    Rails.application.reload_routes!
    account
    allow_any_instance_of(show_controller).to receive(:req).and_return(request)
    allow_any_instance_of(create_controller).to receive(:req).and_return(request)
    allow_any_instance_of(login_controller).to receive(:req).and_return(request)
    account
  end

  after do
    organization.delete
    directory.delete
    application.delete
  end

  describe 'GET /verify' do
    describe 'when subdomain present' do
      let(:subdomain) { random_name }

      describe 'and organization matches subdomain' do
        let(:name_key) { subdomain }

        describe 'with no sptoken' do
          it 'has proper labels' do
            visit 'verify'
            expect(page).to have_css('label', text: 'Email')
          end

          it 'has proper placeholders' do
            visit 'verify'
            expect(find_field('email')['placeholder']).to eq('Email')
          end

          it 'has proper text' do
            visit 'verify'
            expect(page).to have_content(
              "Enter your email address below and we'll resend your account
              verification email.  You will be sent an email which you will
              need to open to continue. You may need to check your spam
              folder."
            )
          end

          it 'does not blow up with wrong path helpers when login is disabled' do
            allow(configuration.web.login).to receive(:enabled).and_return(false)

            Rails.application.reload_routes!

            visit 'verify'

            expect(page.status_code).to eq(200)
            expect(page).not_to have_content('Back to Log In')
          end
        end

        describe 'with invalid sptoken' do
          it 'renders form with error text' do
            visit 'verify?sptoken=INVALID-SPTOKEN'
            expect(page).to have_content(
              'This verification link is no longer valid. '\
              'Please request a new link from the form below.'
            )
          end
        end

        describe 'with valid sptoken' do
          it 'redirects to login uri' do
            visit "verify?sptoken=#{sptoken}"
            expect(page).to have_current_path('/login?status=verified')
          end

          context 'auto login enabled' do
            before do
              allow(configuration.web.register).to receive(:auto_login).and_return(true)
            end

            it 'redirects to root and sets cookies' do
              visit "verify?sptoken=#{sptoken}"

              expect(current_path).to eq('/')
              expect(page).to have_content 'Root page'
              expect(page.driver.request.cookies['access_token']).to be
              expect(page.driver.request.cookies['refresh_token']).to be
            end
          end
        end
      end

      describe "and organization doesn't match subdomain" do
        let(:name_key) { random_name }

        it 'should redirect to parent domain' do
          allow_any_instance_of(show_controller).to receive(:organization_unresolved?).and_return(false)
          visit 'forgot'
          expect(page).to have_css('label', text: 'Enter your organization name to continue')
        end
      end
    end

    describe 'when subdomain not present' do
      let(:subdomains) { [] }
      let(:name_key) { random_name }

      it 'should show the organization name key field' do
        allow_any_instance_of(show_controller).to receive(:organization_unresolved?).and_return(false)
        visit 'forgot'
        expect(page).to have_css('label', text: 'Enter your organization name to continue')
      end
    end
  end

  describe 'POST /verify' do
    context 'auto login disabled' do
      describe 'when subdomain present' do
        let(:subdomain) { random_name }

        describe 'and organization matches subdomain' do
          let(:name_key) { subdomain }

          it 'redirects to login page with status unverified' do
            visit 'verify'
            fill_in 'email', with: account.email
            click_button 'Submit'
            expect(page).to have_current_path('/login?status=unverified')
            expect(page).to have_content(
              'Your account verification email has been sent! Before you can log into your account, '\
              'you need to activate your account by clicking the link we sent to your inbox. '\
              'Didn\'t get the email?'
            )
          end
        end

        describe "and organization doesn't match subdomain" do
          let(:name_key) { random_name }
          before do
            allow_any_instance_of(show_controller).to receive(:organization_unresolved?).and_return(false)
          end

          describe 'submit correct organization name key' do
            it 'should redirect back to verify' do
              visit 'verify'
              expect(page).to have_css('label', text: 'Enter your organization name to continue')

              fill_in 'Enter your organization name to continue', with: name_key
              allow_any_instance_of(show_controller).to receive(:current_organization).and_return(organization)
              click_button 'Submit'
              expect(page).to have_css('label', text: 'Email')
            end
          end

          describe 'submit incorrect organization name key' do
            it 'should show warning' do
              visit 'verify'
              expect(page).to have_css('label', text: 'Enter your organization name to continue')

              fill_in 'Enter your organization name to continue', with: 'incorrect-name-key'
              click_button 'Submit'

              expect(page).to have_content 'Organization could not be found'
            end
          end
        end
      end

      describe 'when subdomain missing' do
        let(:subdomains) { [] }
        let(:name_key) { random_name }
        before do
          allow_any_instance_of(show_controller).to receive(:organization_unresolved?).and_return(false)
        end

        describe 'submit correct organization name key' do
          it 'should redirect back to verify' do
            visit 'verify'
            expect(page).to have_css('label', text: 'Enter your organization name to continue')

            fill_in 'Enter your organization name to continue', with: name_key
            allow_any_instance_of(show_controller).to receive(:current_organization).and_return(organization)
            click_button 'Submit'
            expect(page).to have_css('label', text: 'Email')
          end
        end

        describe 'submit incorrect organization name key' do
          it 'should show warning' do
            visit 'verify'
            expect(page).to have_css('label', text: 'Enter your organization name to continue')

            fill_in 'Enter your organization name to continue', with: 'incorrect-name-key'
            click_button 'Submit'

            expect(page).to have_content 'Organization could not be found'
          end
        end
      end
    end
  end
end
