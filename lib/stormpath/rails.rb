require 'stormpath-sdk'
require 'stormpath/rails/engine'
require 'stormpath/rails/configuration'
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
    autoload :AccountStatus, 'stormpath/rails/account_status'
    autoload :IdSite, 'stormpath/rails/id_site'
  end
end