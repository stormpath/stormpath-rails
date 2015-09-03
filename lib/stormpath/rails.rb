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
    autoload :Social, 'stormpath/rails/social'

    module UserConfig
      autoload :ApiKey, 'stormpath/rails/user_config/api_key'
      autoload :Application, 'stormpath/rails/user_config/application'
      autoload :ForgotPassword, 'stormpath/rails/user_config/forgot_password'
      autoload :IdSite, 'stormpath/rails/user_config/id_site'
      autoload :VerifyEmail, 'stormpath/rails/user_config/verify_email'
      autoload :Facebook, 'stormpath/rails/user_config/facebook'
      autoload :Login, 'stormpath/rails/user_config/login'
      autoload :Logout, 'stormpath/rails/user_config/logout'
      autoload :Register, 'stormpath/rails/user_config/register'
    end
  end
end
