require 'rails/generators/base'
require 'rails/generators/active_record'

module Stormpath
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      def create_stormpath_initializer
        copy_file 'stormpath.rb', 'config/initializers/stormpath.rb'
      end

      def create_user_model
        unless File.exists? 'app/models/user.rb'
          copy_file 'user.rb', 'app/models/user.rb'
        end
      end
    end
  end
end