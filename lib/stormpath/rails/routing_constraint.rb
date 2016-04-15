module Stormpath
  module Rails
    module RoutingConstraint
      def self.matches?(request)
        ContentTypeNegotiator.new(request.headers['HTTP_ACCEPT']).handle_by_stormpath?
      end
    end
  end
end
