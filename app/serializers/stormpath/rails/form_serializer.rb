module Stormpath
  module Rails
    class FormSerializer
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
          .select  { |_field, properties| properties[:enabled] && properties[:visible] }
          .each    { |_field, properties| properties.delete(:enabled) }
          .each    { |_field, properties| properties.delete(:visible) }
          .deep_transform_keys { |key| key.to_s.camelize(:lower).to_sym }
          .sort_by { |field, _properties| config.form.field_order.index(field.to_s) || Float::INFINITY }
          .map     { |field, properties| properties.merge(name: field) }
      end
    end
  end
end
