module Stormpath
  module Rails
    class ProfileController < BaseController
      def show
        render json: ProfileSerializer.to_h(current_account)
      end
    end
  end
end
