require 'stormpath-sdk'
require 'stormpath/rails/engine'
require 'stormpath/rails/config/read_file'
require 'stormpath/rails/config/application_resolution'
require 'stormpath/rails/config/account_store_verification'
require 'stormpath/rails/config/dynamic_configuration'
require 'stormpath/rails/configuration'
require 'virtus'

module Stormpath
  module Rails
    autoload :Client, 'stormpath/rails/client'
    autoload :Authentication, 'stormpath/rails/authentication'
    autoload :Controller, 'stormpath/rails/controller'
    autoload :Version, 'stormpath/rails/version'
    autoload :Social, 'stormpath/rails/social'
    autoload :ContentTypeNegotiator, 'stormpath/rails/content_type_negotiator'
    autoload :RoutingConstraint, 'stormpath/rails/routing_constraint'
    autoload :InvalidSptokenError, 'stormpath/rails/errors/invalid_sptoken_error'
    autoload :NoSptokenError, 'stormpath/rails/errors/no_sptoken_error'
  end
end
