module Stormpath
  module Rails
    module Social
      class GithubController < Stormpath::Rails::BaseController
        def create
          respond_to do |format|
            format.json { render nothing: true, status: 404 }
            format.html { redirect_to stormpath_config.web.login.next_uri }
          end
        end
      end
    end
  end
end
