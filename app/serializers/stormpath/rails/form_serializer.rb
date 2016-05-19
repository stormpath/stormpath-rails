module Stormpath
  module Rails
    class FormSerializer
      # High number used when a field is missing from the field order array,
      # to position all the missing ones at the back of the array
      HIGH_NUMBER = 99

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

      def config
        fail NotImplementedError
      end

      def form_fields
        config
          .form
          .fields
          .to_h
          .select  { |_field, properties| properties[:enabled] }
          .each    { |_field, properties| properties.delete(:enabled) }
          .deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
          .sort_by { |field, _properties| config.form.field_order.index(field.to_s) || HIGH_NUMBER }
          .map     { |field, properties| properties.merge(name: field) }
      end
    end
  end
end
