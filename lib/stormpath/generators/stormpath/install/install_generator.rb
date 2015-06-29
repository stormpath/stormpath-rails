require 'rails/generators/base'
require 'rails/generators/active_record'

module Stormpath
  module Generators
    class InstallGenerator < Rails::Generators::base
      include Rails::Generators::Migration
    end
  end
end