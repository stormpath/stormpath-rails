module Stormpath
  module Rails
    module RoutingConstraint
      def self.matches?(request)
        !!ContentTypeNegotiator.new(request.headers['HTTP_ACCEPT']).call
      end
    end
  end
end
