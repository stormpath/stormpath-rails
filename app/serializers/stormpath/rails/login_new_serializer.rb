module Stormpath
  module Rails
    class LoginNewSerializer
      attr_reader :account

      def self.to_h
        new.to_h
      end

      def to_h
        {
          form: login_config.form.to_h,
          accountStores: []
        }
      end

      def login_config
        Stormpath::Rails.config.web.login
      end
    end
  end
end
