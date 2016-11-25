require 'spec_helper'

describe 'Registration POST', type: :request, vcr: true do
  describe 'HTTP_ACCEPT=application/json' do
    def json_register_post(attrs = {})
      post '/register', attrs, 'HTTP_ACCEPT' => 'application/json'
    end

    def response_body
      JSON.parse(response.body)
    end

    def error_message
      response_body['message']
    end

    def delete_account
      return unless response.status == 200
      Stormpath::Rails::Client.application.accounts.get(response_body['account']['href']).delete
    end

    let(:account_attrs) { attributes_for(:account_without_username) }
    let(:account_attrs_with_blank_given_name) do
      attributes_for(:account_without_username, given_name: nil)
    end
    let(:account_attrs_with_blank_email) do
      attributes_for(:account_without_username, email: nil)
    end
    let(:account_attrs_with_blank_password) do
      attributes_for(:account_without_username, password: nil)
    end

    describe 'json is enabled' do
      describe 'submit valid form' do
        after { delete_account }

        it 'respond with status 200' do
          json_register_post(account_attrs)
          expect(response.status).to eq(200)
        end

        describe 'with autologin enabled' do
          before do
            allow(web_config.register).to receive(:auto_login).and_return(true)
          end

          it 'respond with status 200 and sets cookies' do
            json_register_post(account_attrs)
            expect(response.status).to eq(200)
            expect(response.cookies['access_token']).to be
            expect(response.cookies['refresh_token']).to be
          end
        end
      end

      describe 'submit blank givenName' do
        it 'respond with status 400' do
          json_register_post(account_attrs_with_blank_given_name)
          expect(response.status).to eq(400)
          expect(error_message).to eq('First Name is required.')
        end
      end

      describe 'submit blank, enabled but not required middleName' do
        before do
          web_config.register.form.fields.middle_name.enabled = true
          web_config.register.form.fields.middle_name.required = false
          reload_form_class
        end

        after do
          web_config.register.form.fields.middle_name.enabled = true
          web_config.register.form.fields.middle_name.required = false
        end

        after { delete_account }

        it 'respond with status 200' do
          json_register_post(account_attrs)
          expect(response.status).to eq(200)
        end
      end

      describe 'submit already existing email' do
        let!(:account) do
          Stormpath::Rails::Client.application.accounts.create(
            email: 'example@test.com',
            givenName: 'Example',
            surname: 'Test',
            password: 'Pa$$W0RD'
          )
        end

        after { account.delete }

        it 'respond with status 400' do
          json_register_post(
            email: 'example@test.com',
            givenName: 'Example',
            surname: 'Test',
            password: 'Pa$$W0RD'
          )
          expect(response.status).to eq(400)
          expect(error_message).to eq(
            'Account with that email already exists.  Please choose another email.'
          )
        end
      end

      describe 'when email not required and submitted without email' do
        before do
          web_config.register.form.fields.email.required = false
          reload_form_class
        end

        after do
          web_config.register.form.fields.email.required = true
        end

        it 'respond with status 400' do
          json_register_post(account_attrs_with_blank_email)
          expect(response.status).to eq(400)
          expect(error_message).to eq('Account email address is required; it cannot be null, empty, or blank.')
        end
      end

      describe 'when password not required and submitted without password' do
        before do
          web_config.register.form.fields.password.required = false
          reload_form_class
        end

        after do
          web_config.register.form.fields.password.required = true
        end

        it 'respond with status 400' do
          json_register_post(account_attrs_with_blank_password)
          expect(response.status).to eq(400)
          expect(error_message).to eq('Account password is required; it cannot be null, empty, or blank.')
        end
      end

      describe 'add a custom field' do
        describe 'that is required' do
          before do
            web_config.register.form.fields.age = OpenStruct.new(
              enabled: true,
              visible: true,
              label: 'Age',
              placeholder: 'Age',
              required: true,
              type: 'number'
            )
            reload_form_class
          end

          after { web_config.register.form.fields.delete_field(:age) }

          describe 'and submitted' do
            describe 'nested inside the root' do
              after { delete_account }

              it 'respond with status 200' do
                json_register_post(account_attrs.merge(age: 25))
                expect(response.status).to eq(200)
                account = Stormpath::Rails::Client.application.accounts.get(
                  response_body['account']['href']
                )
                expect(account.custom_data[:age]).to eq('25')
              end
            end

            describe 'nested inside the customData hash' do
              after { delete_account }

              it 'respond with status 200' do
                json_register_post(account_attrs.merge(customData: { age: 25 }))
                expect(response.status).to eq(200)
                account = Stormpath::Rails::Client.application.accounts.get(
                  response_body['account']['href']
                )
                expect(account.custom_data[:age]).to eq('25')
              end
            end
          end

          describe 'and not submitted' do
            it 'respond with status 400' do
              json_register_post(account_attrs)
              expect(error_message).to eq('Age is required.')
              expect(response.status).to eq(400)
            end
          end
        end

        describe 'and its not required' do
          before do
            web_config.register.form.fields.age = OpenStruct.new(
              enabled: true,
              visible: true,
              label: 'Age',
              placeholder: 'Age',
              required: false,
              type: 'number'
            )
            reload_form_class
          end

          after { web_config.register.form.fields.delete_field(:age) }

          describe 'nested inside the root' do
            after { delete_account }

            it 'respond with status 200' do
              json_register_post(account_attrs.merge(age: 25))
              expect(response.status).to eq(200)
            end
          end

          describe 'nested inside the customData hash' do
            after { delete_account }

            it 'respond with status 200' do
              json_register_post(account_attrs.merge(customData: { age: 25 }))
              expect(response.status).to eq(200)
            end
          end
        end
      end

      describe 'enable password confirmation' do
        before do
          web_config.register.form.fields.confirm_password.enabled = true
          reload_form_class
        end

        after do
          web_config.register.form.fields.confirm_password.enabled = false
        end

        describe 'if successfull' do
          after { delete_account }

          it 'responds with status 200 if matches' do
            json_register_post(account_attrs.merge(confirmPassword: 'Password1337'))
            expect(response.status).to eq(200)
          end
        end

        it 'responds with status 400 if does not match' do
          json_register_post(account_attrs.merge(confirmPassword: 'Pa$$'))
          expect(response.status).to eq(400)
          expect(error_message).to eq('Passwords do not match')
        end
      end

      describe 'disable the givenName and set it to UNKNOWN' do
        before do
          web_config.register.form.fields.given_name.enabled = false
          reload_form_class
        end

        after do
          web_config.register.form.fields.given_name.enabled = true
        end

        after { delete_account }

        it 'respond with status 200' do
          json_register_post(account_attrs.except(:given_name))
          expect(response.status).to eq(200)
          expect(response_body['account']['givenName']).to eq('UNKNOWN')
        end
      end

      describe 'disable the surname and set it to UNKNOWN' do
        before do
          web_config.register.form.fields.surname.enabled = false
          reload_form_class
        end

        after do
          web_config.register.form.fields.surname.enabled = true
        end

        after { delete_account }

        it 'respond with status 200' do
          json_register_post(account_attrs.except(:surname))
          expect(response.status).to eq(200)
          expect(response_body['account']['surname']).to eq('UNKNOWN')
        end
      end

      describe 'dont require givenName, submit blank and set it to UNKNOWN' do
        before do
          web_config.register.form.fields.given_name.required = false
          reload_form_class
        end

        after do
          web_config.register.form.fields.given_name.required = true
        end

        after { delete_account }

        it 'respond with status 200' do
          json_register_post(account_attrs.except(:given_name))
          expect(response.status).to eq(200)
          expect(response_body['account']['givenName']).to eq('UNKNOWN')
        end
      end

      describe 'dont require surname, submit blank and set it to UNKNOWN' do
        before do
          web_config.register.form.fields.surname.required = false
          reload_form_class
        end

        after do
          web_config.register.form.fields.surname.required = true
        end

        after { delete_account }

        it 'respond with status 200' do
          json_register_post(account_attrs.except(:surname))
          expect(response.status).to eq(200)
          expect(response_body['account']['surname']).to eq('UNKNOWN')
        end
      end

      describe 'unknown field submission' do
        describe 'nested inside the root' do
          it 'respond with status 400' do
            json_register_post(account_attrs.merge(age: 25))
            expect(response.status).to eq(400)
            expect(error_message).to eq("Can't submit arbitrary data: age")
          end
        end

        describe 'nested inside the customData hash' do
          it 'respond with status 400' do
            json_register_post(account_attrs.merge(customData: { age: 25 }))
            expect(response.status).to eq(400)
            expect(error_message).to eq("Can't submit arbitrary data: age")
          end
        end
      end

      describe 'a regular field that is disabled' do
        before do
          web_config.register.form.fields.middle_name.enabled = false
          reload_form_class
        end

        after do
          web_config.register.form.fields.middle_name.enabled = true
        end

        it 'respond with status 400' do
          json_register_post(account_attrs.merge(middleName: 'Hako'))
          expect(response.status).to eq(400)
          expect(error_message).to eq("Can't submit arbitrary data: middle_name")
        end
      end
    end

    describe 'json is disabled' do
      context 'multitenancy enabled' do
        let(:multitenancy_config) { configuration.web.multi_tenancy }
        let(:directory) { test_client.directories.create(attributes_for(:directory)) }
        let(:organization) { test_client.organizations.create(attributes_for(:organization)) }

        before do
          allow(multitenancy_config).to receive(:enabled).and_return(true)
          allow(multitenancy_config).to receive(:strategy).and_return('subdomain')
          allow(configuration.web).to receive(:domain_name).and_return('infinum.co')
          map_account_store(test_application, directory, 10, false, false)
          map_account_store(test_application, organization, 11, false, false)
          map_organization_store(directory, organization, true)
        end

        after do
          organization.delete
          directory.delete
        end

        context 'existing organization' do
          context 'organization_name_key is in request.host' do
            let(:request_host) do
              { 'HTTP_HOST' => "#{organization.name_key}.#{configuration.web.domain_name}" }
            end

            it 'should successfully register' do
              post '/register', account_attrs, request_host
              expect(response.status).to eq(302)
              expect(response).to redirect_to('/')
              expect(organization.accounts.count).to eq 1
            end
          end

          context 'organization_name_key is in request.body' do
            it 'successfull login' do
              post '/login', login: multi_account_attrs[:email], password: multi_account_attrs[:password], organization_name_key: organization.name_key
              expect(response.status).to eq(302)
              expect(response).to redirect_to('/')
            end
          end
        end

        context 'non-existing organization' do
          let(:request_host) do
            { 'HTTP_HOST' => "non-existing-rails-org.#{configuration.web.domain_name}" }
          end

          it 'should log in successfully because the organization_name_key is nil' do
            post '/login', { login: multi_account_attrs[:email], password: multi_account_attrs[:password] }, request_host
            expect(response.status).to eq(302)
            expect(response).to redirect_to('/')
          end
        end
      end
    end
  end
end
