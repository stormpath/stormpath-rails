module Stormpath
  module Rails
    class ConfigFile
      attr_reader :type

      def initialize(type = :default)
        @type = type
      end

      def hash
        @hash ||= snakecased_hash
      end

      private

      def snakecased_hash
        camelized_hash.deep_transform_keys(&:underscore)
      end

      def camelized_hash
        YAML.load_file(config_path)
      end

      def config_path
        {
          default: File.expand_path('../../../../config/default_config.yml', __FILE__),
          user_defined: ::Rails.application.root.join('config/stormpath.yml')
        }[type]
      end
    end
  end
end
