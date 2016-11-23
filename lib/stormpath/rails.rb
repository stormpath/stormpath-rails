require 'stormpath-sdk'
require 'stormpath/rails/engine'
require 'stormpath/rails/config/read_file'
require 'stormpath/rails/config/application_resolution'
require 'stormpath/rails/config/account_store_verification'
require 'stormpath/rails/config/dynamic_configuration'
require 'stormpath/rails/config/social_login_verification'
require 'stormpath/rails/configuration'
require 'stormpath/rails/router'
require 'virtus'

module Stormpath
  module Rails
    autoload :Client, 'stormpath/rails/client'
    autoload :Controller, 'stormpath/rails/controller'
    autoload :Version, 'stormpath/rails/version'
    autoload :Social, 'stormpath/rails/social'
    autoload :ApiKey, 'stormpath/rails/api_key'
    autoload :ContentTypeNegotiator, 'stormpath/rails/content_type_negotiator'
    autoload :RoutingConstraint, 'stormpath/rails/routing_constraint'
    autoload :InvalidSptokenError, 'stormpath/rails/errors/invalid_sptoken_error'
    autoload :NoSptokenError, 'stormpath/rails/errors/no_sptoken_error'
    autoload :NoFacebookAuthorizationError, 'stormpath/rails/errors/no_facebook_authorization_error'
    autoload :NoGithubAuthorizationError, 'stormpath/rails/errors/no_github_authorization_error'
    autoload :FacebookAuthCodeExchange, 'stormpath/rails/facebook_auth_code_exchange'
    autoload :GithubAuthCodeExchange, 'stormpath/rails/github_auth_code_exchange'
    autoload :EnvNamesWarning, 'stormpath/rails/env_names_warning'
  end
end
