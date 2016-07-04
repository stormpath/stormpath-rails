module Stormpath
  module Rails
    class InvalidSptokenError < ArgumentError
      def status
        404
      end
    end
  end
end
