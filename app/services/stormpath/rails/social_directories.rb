module Stormpath
  module Rails
    class SocialDirectories
      def self.for(application)
        new(application).call
      end

      def initialize(application)
        @application = application
      end

      def call
        application.account_store_mappings.select do |mapping|
          account_store = mapping.account_store
          account_store if social_directory?(account_store)
        end.map(&:account_store)
      end

      private

      def social_directory?(account_store)
        account_store.class == Stormpath::Resource::Directory &&
          account_store.provider.respond_to?(:client_id)
      end

      attr_reader :application
    end
  end
end
