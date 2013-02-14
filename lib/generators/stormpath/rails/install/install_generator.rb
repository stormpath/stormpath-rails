module Stormpath
  module Rails
    module Generators
      class InstallGenerator < ::Rails::Generators::Base
        source_root File.expand_path('../../templates', __FILE__)

        def create_initializer_file
          template "stormpath.yml", "config/stormpath.yml"
        end
      end
    end
  end
end
