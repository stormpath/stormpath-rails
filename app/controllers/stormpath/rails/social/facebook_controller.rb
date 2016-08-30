module Stormpath
  module Rails
    module Social
      class FacebookController < Stormpath::Rails::BaseController
        def create
          uri = URI "https://graph.facebook.com/v2.7/oauth/access_token"
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true

          post_params = URI.encode_www_form(
            client_id: Stormpath::Rails.config.web.facebook_app_id,
            client_secret: Stormpath::Rails.config.web.facebook_app_secret,
            redirect_uri: facebook_callback_url,
            code: params[:code]
          )

          response = http.post(uri, post_params)
          json_response = JSON.parse(response.body)
          access_token = json_response['access_token']
          token_type = json_response['token_type'].try(:capitalize)

          request = Stormpath::Provider::AccountRequest.new(:facebook, :access_token, access_token)

          provider_account = Stormpath::Rails::Client.application.get_provider_account(request)

          account = provider_account.account

          AccountLoginWithStormpathToken.new(
            cookies, account,
            Stormpath::Rails::Client.application,
            Stormpath::Rails::Client.client.data_store.api_key
          ).call

          respond_to do |format|
            format.json { render nothing: true, status: 404 }
            format.html { redirect_to stormpath_config.web.login.next_uri }
          end
        end
      end
    end
  end
end
