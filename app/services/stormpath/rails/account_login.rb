module Stormpath
  module Rails
    class AccountLogin
      attr_reader :cookie_jar, :login, :password

      def self.call(cookie_jar, login, password)
        new(cookie_jar, login, password).call
      end

      def initialize(cookie_jar, login, password)
        @cookie_jar = cookie_jar
        @login      = login
        @password   = password
      end

      def call
        form.save
        fail(Stormpath::Error, form.errors.full_messages.first) if form.invalid?
        TokenCookieSetter.call(cookie_jar, form.authentication_result)
      end

      private

      def form
        @form ||= LoginForm.new(login: login, password: password)
      end
    end
  end
end
