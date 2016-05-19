module Stormpath
  module Rails
    class LoginNewSerializer
      attr_reader :account

      def self.to_h
        new.to_h
      end

      def to_h
        {
          form: {
            fields: form_fields
          },
          accountStores: []
        }
      end

      private

      def login_config
        Stormpath::Rails.config.web.login
      end

      def form_fields
        login_config
          .form
          .fields
          .to_h
          .select { |_field, properties| properties[:enabled] }
          .each   {|_field, properties| properties.delete(:enabled) }
          .map { |field, properties| properties.merge(name: field) }
      end
    end
  end
end
