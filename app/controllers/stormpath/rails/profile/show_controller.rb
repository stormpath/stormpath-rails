module Stormpath
  module Rails
    module Profile
      class ShowController < BaseController
        before_action :authenticate_account!

        def call
          response.headers['Cache-Control'] = 'no-cache, no-store'
          response.headers['Pragma'] = 'no-cache'
          render json: ProfileSerializer.to_h(current_account)
        end
      end
    end
  end
end
