module Stormpath
  module Rails
    class ProfileSerializer
      attr_reader :account_href

      def self.to_h(account)
        new(account).to_h
      end

      def initialize(account)
        @account_href = account.href
      end

      def to_h
        @to_h ||= AccountSerializer.to_h(account).deep_merge(account: expanded_resources_hash)
      end

      private

      def expansions
        Stormpath::Rails
          .config
          .web
          .me
          .expand
          .to_h
          .select { |_relation, should_expand| should_expand == true }
          .keys
      end

      def expansion_resource
        Stormpath::Resource::Expansion.new(expansions)
      end

      def expanded_resources_hash
        {}.tap do |hash|
          expansions.each do |expansion|
            expanded_resource = account.send(expansion)
            expansion_name = expansion.to_s.camelize(:lower).to_sym

            hash[expansion_name] = if expanded_resource.is_a?(Stormpath::Resource::Collection)
                                     expanded_resource.map do |single_resource|
                                       properties_serializer(single_resource)
                                     end
                                   else
                                     properties_serializer(expanded_resource)
                                   end
          end
        end
      end

      def properties_serializer(resource)
        resource.send(:materialize)
        properties = resource.properties

        if resource.is_a?(Stormpath::Resource::CustomData)
          properties
        else
          properties.delete_if { |_key, value| value.is_a?(Hash) }
          properties.transform_keys do |key|
            key.to_s.camelize(:lower).to_sym
          end
        end
      end

      def account
        @account ||= Stormpath::Rails::Client.client.accounts.get(account_href, expansion_resource)
      end
    end
  end
end
