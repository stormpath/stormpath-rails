require 'stormpath-sdk'
require 'stormpath/rails/engine'
require 'stormpath/rails/config_file'
require 'stormpath/rails/configuration'
require 'stormpath/rails/yaml_configuration'
require 'virtus'

module Stormpath
  module Rails
    autoload :Client, 'stormpath/rails/client'
    autoload :Authentication, 'stormpath/rails/authentication'
    autoload :Session, 'stormpath/rails/session'
    autoload :Controller, 'stormpath/rails/controller'
    autoload :Account, 'stormpath/rails/account'
    autoload :Version, 'stormpath/rails/version'
    autoload :User, 'stormpath/rails/user'
    autoload :AuthenticationStatus, 'stormpath/rails/authentication_status'
    autoload :OauthAuthenticationStatus, 'stormpath/rails/oauth_authentication_status'
    autoload :AccountStatus, 'stormpath/rails/account_status'
    autoload :Social, 'stormpath/rails/social'
    autoload :ContentTypeNegotiator, 'stormpath/rails/content_type_negotiator'
    autoload :RoutingConstraint, 'stormpath/rails/routing_constraint'
  end
end
