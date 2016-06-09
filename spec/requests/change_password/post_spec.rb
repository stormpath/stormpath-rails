require 'spec_helper'

describe 'ChangePassword POST', type: :request, vcr: true do
  def response_body
    JSON.parse(response.body)
  end

  let(:account) { Stormpath::Rails::Client.application.accounts.create(account_attrs) }

  let(:account_attrs) do
    {
      email: 'example@test.com',
      given_name: 'Example',
      surname: 'Test',
      password: 'Pa$$W0RD',
      username: 'SirExample'
    }
  end

  let(:password_reset_token) do
    Stormpath::Rails::Client.application.password_reset_tokens.create(
      email: account.email
    ).token
  end

  let(:new_password) { 'neWpa$$W0Rd' }

  after { account.delete }

  context 'application/json' do
    def json_change_post(attrs = {})
      post '/change', attrs, 'HTTP_ACCEPT' => 'application/json'
    end

    context 'password reset enabled' do
      before do
        enable_change_password
        Rails.application.reload_routes!
      end

      context 'without sptoken' do
        it 'return 400' do
          json_change_post(password: new_password)
          expect(response.status).to eq(400)
          expect(response_body['message']).to eq('sptoken parameter not provided.')
        end
      end

      context 'invalid sptoken' do
        it 'return 404' do
          json_change_post(password: new_password, sptoken: 'INVALIDSPTOKEN')
          expect(response.status).to eq(404)
          expect(response_body['message']).to eq(
            'This password reset request does not exist. Please request a new password reset.'
          )
        end
      end

      context 'valid sptoken' do
        context 'auto login enabled' do
          before do
            allow(configuration.web.change_password).to receive(:auto_login).and_return(true)
          end

          context 'valid password' do
            it 'return 200' do
              json_change_post(
                sptoken: password_reset_token,
                password: new_password
              )
              expect(response.status).to eq(200)
            end

            it 'matches schema' do
              json_change_post(
                sptoken: password_reset_token,
                password: new_password
              )
              expect(response).to match_response_schema(:login_response, strict: true)
            end

            it 'sets login cookies' do
              json_change_post(
                sptoken: password_reset_token,
                password: new_password
              )
              expect(response.cookies['access_token']).to be
              expect(response.cookies['refresh_token']).to be
            end
          end
        end

        context 'auto login disabled' do
          context 'valid password' do
            it 'return 200' do
              json_change_post(
                sptoken: password_reset_token,
                password: new_password
              )
              expect(response.status).to eq(200)
              expect(response.body).to be_empty
            end
          end
        end

        context 'invalid password' do
          it 'return 400' do
            json_change_post(
              sptoken: password_reset_token,
              password: 'short'
            )
            expect(response.status).to eq(400)
            expect(response_body['message']).to eq('Account password minimum length not satisfied.')
          end
        end

        context 'no password' do
          it 'return 400' do
            json_change_post(
              sptoken: password_reset_token
            )
            expect(response.status).to eq(400)
            expect(response_body['message']).to eq('account password cannot be null, empty, or blank.')
          end
        end
      end
    end

    context 'password reset disabled' do
      before do
        disable_change_password
        Rails.application.reload_routes!
      end

      it 'return 404' do
        json_change_post
        expect(response.status).to eq(404)
      end
    end
  end
end
