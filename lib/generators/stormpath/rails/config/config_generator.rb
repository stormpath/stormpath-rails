module Stormpath
  module Rails
    module Generators
      class ConfigGenerator < ::Rails::Generators::Base
        def create_initializer_file
          create_file "config/stormpath.yml", "development:
  href: <%= ENV['STORMPATH_URL'] %>
  root: https://api.stormpath.com/v1/directories/<root directory uid>

test:
  href: <%= ENV['STORMPATH_URL'] %>
  root: https://api.stormpath.com/v1/directories/<root directory uid>

production:
  href: <%= ENV['STORMPATH_URL'] %>
  root: https://api.stormpath.com/v1/directories/<root directory uid>
"
        end
      end
    end
  end
end
