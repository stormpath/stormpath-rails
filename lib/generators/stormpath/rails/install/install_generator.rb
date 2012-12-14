module Stormpath
  module Rails
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        def create_initializer_file
          create_file "config/stormpath.yml", "common:
  href: <%= ENV['STORMPATH_URL'] %>
  application: https://api.stormpath.com/v1/applications/<application id>

development:
  root: https://api.stormpath.com/v1/directories/<root directory id>

test:
  root: https://api.stormpath.com/v1/directories/<root directory id>

production:
  root: https://api.stormpath.com/v1/directories/<root directory id>
"
        end
      end
    end
  end
end
