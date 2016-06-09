module Stormpath
  module Rails
    class Client
      class << self
        attr_accessor :connection
      end

      def self.create_stormpath_account(registration_params)
        begin
          result = application.accounts.create build_account(registration_params)
        rescue Stormpath::Error => error
          result = error.message
        end

        AccountStatus.new(result)
      end

      def self.authenticate(user)
        begin
          result = application.authenticate_account build_username_password_request(user)
        rescue Stormpath::Error => error
          result = error
        end

        AuthenticationStatus.new(result)
      end

      def self.authenticate_oauth(password_grant_request)
        begin
          result = application.authenticate_oauth(password_grant_request)
        rescue Stormpath::Error => error
          result = error
        end

        OauthAuthenticationStatus.new(result)
      end

      def self.reset_password(email)
        begin
          result = application.send_password_reset_email email
        rescue Stormpath::Error => error
          result = error.message
        end

        AccountStatus.new(result)
      end

      def self.verify_email_token(token)
        begin
          result = client.accounts.verify_email_token token
        rescue Stormpath::Error => error
          result = error.message
        end

        AccountStatus.new(result)
      end

      def self.verify_password_token(token)
        begin
          result = application.password_reset_tokens.get(token).account
        rescue Stormpath::Error => error
          result = error.message
        end

        AccountStatus.new(result)
      end

      def self.handle_id_site_callback(url)
        response = application.handle_id_site_callback(url)
        client.accounts.get response.account_href
      end

      def self.id_site_url(options)
        application.create_id_site_url callback_uri: options[:callback_uri], path: options[:path]
      end

      def self.update_password(account, password)
        begin
          account = client.accounts.get account
          account.password = password
          result = account.save
        rescue Stormpath::Error => error
          result = error.message
        end

        AccountStatus.new(result)
      end

      def self.create_omniauth_user(provider, access_token)
        request = Stormpath::Provider::AccountRequest.new(provider, :access_token, access_token)
        application.get_provider_account(request)
      end

      def self.application
        client.applications.get Stormpath::Rails.config.application.href
      end

      def self.client
        self.connection ||= Stormpath::Client.new(
          api_key: {
            id: ENV['STORMPATH_API_KEY_ID'],
            secret: ENV['STORMPATH_API_KEY_SECRET']
          }
        )
      end

      def self.get_account(href)
        application.accounts.get href
      end

      private

      def self.build_username_password_request(user)
        Stormpath::Authentication::UsernamePasswordRequest.new user.email, user.password
      end

      def self.build_account(registration_params)
        Stormpath::Resource::Account.new(registration_params)
      end
    end
  end
end
