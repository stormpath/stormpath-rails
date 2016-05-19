module Stormpath
  module Rails
    class LoginNewSerializer
      # High number used when a field is missing from the field order array,
      # to position all the missing ones at the back of the array
      HIGH_NUMBER = 99

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
          .select  { |_field, properties| properties[:enabled] }
          .each    { |_field, properties| properties.delete(:enabled) }
          .sort_by { |field, _properties| login_config.form.field_order.index(field.to_s) || HIGH_NUMBER }
          .map     { |field, properties| properties.merge(name: field) }
      end
    end
  end
end
