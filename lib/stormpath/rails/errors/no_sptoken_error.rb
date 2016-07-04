module Stormpath
  module Rails
    class NoSptokenError < ArgumentError
      def status
        400
      end
    end
  end
end
