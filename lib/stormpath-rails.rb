require 'stormpath-sdk'
require 'stormpath/engine'
require 'stormpath/controller'
require 'stormpath/configuration'

module Stormpath
  module Rails
    autoload :Client, 'stormpath/rails/client'
    autoload :Account, 'stormpath/rails/account'
  end
end