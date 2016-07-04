module Stormpath
  module Rails
    class NoSptokenError < ArgumentError
      def message
        'sptoken parameter not provided.'
      end

      def status
        400
      end
    end
  end
end
