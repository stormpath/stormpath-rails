module Stormpath
  module Rails
    module Oauth2
      class NewController < BaseController
        def call
          render status: 405, nothing: true
        end
      end
    end
  end
end
