module Stormpath
  module Rails
    class ReadConfigFile
      attr_reader :file_path

      def initialize(file_path)
        @file_path = file_path
      end

      def hash
        @hash ||= snakecased_hash
      end

      private

      def snakecased_hash
        camelized_hash.deep_transform_keys(&:underscore)
      end

      def camelized_hash
        YAML.load(evaluated_file)
      end

      def evaluated_file
        ERB.new(file).result(binding)
      end

      def file
        File.read(file_path)
      end
    end
  end
end
