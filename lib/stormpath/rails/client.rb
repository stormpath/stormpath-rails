module Stormpath
  module Rails
    class Client
      class << self
        attr_accessor :connection
      end

      def self.create_stormpath_account(user)
        begin
          result = application.accounts.create build_account(user)
        rescue Stormpath::Error => error
          result = error.message
        end

        AccountStatus.new(result)
      end

      def self.authenticate(user)
        begin
          result = application.authenticate_account build_username_password_request(user)
        rescue Stormpath::Error => error
          result = error.message
        end

        AuthenticationStatus.new(result)
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

      def self.handle_id_site_callback(url)
        response = application.handle_id_site_callback(url)
        client.accounts.get response.account_href
      end

      def self.id_site_url(options)
        application.create_id_site_url callback_uri: options[:callback_uri], path: options[:path]
      end

      def self.account_params(user)
        account_params = user.attributes.select do |k, v|
          %W[given_name surname email username password].include?(k) && !v.nil?
        end

        account_params.merge!("password" => user.password) unless user.password.blank?
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
        self.client.applications.get Stormpath::Rails.config.application.href
      end

      def self.client
        self.connection ||= Stormpath::Client.new(client_options)
      end

      def self.client_options
        Hash.new.tap { |options| options[:api_key_file_location] = Stormpath::Rails.config.api_key.file }
      end

      private

      def self.build_username_password_request(user)
        Stormpath::Authentication::UsernamePasswordRequest.new user.email, user.password
      end

      def self.build_account(user)
        Stormpath::Resource::Account.new account_params(user)
      end
    end
  end
end
