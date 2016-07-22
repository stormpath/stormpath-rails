Rails.application.routes.draw do
  constraints Stormpath::Rails::RoutingConstraint do
    scope module: 'stormpath/rails' do
      # REGISTER
      if Stormpath::Rails.config.web.register.enabled
        get Stormpath::Rails.config.web.register.uri => 'register/new#call', as: :new_register
        post Stormpath::Rails.config.web.register.uri => 'register/create#call', as: :register
      end

      # LOGIN
      if Stormpath::Rails.config.web.login.enabled
        get Stormpath::Rails.config.web.login.uri => 'login/new#call', as: :new_login
        post Stormpath::Rails.config.web.login.uri => 'login/create#call', as: :login
      end

      # LOGOUT
      if Stormpath::Rails.config.web.logout.enabled
        post Stormpath::Rails.config.web.logout.uri => 'logout/create#call', as: :logout
      end

      # FORGOT PASSWORD
      if Stormpath::Rails.config.web.forgot_password.enabled
        get Stormpath::Rails.config.web.forgot_password.uri => 'forgot_password/new#call', as: :new_forgot_password
        post Stormpath::Rails.config.web.forgot_password.uri => 'forgot_password/create#call', as: :forgot_password
      end

      # CHANGE PASSWORD
      if Stormpath::Rails.config.web.change_password.enabled
        get Stormpath::Rails.config.web.change_password.uri => 'change_password/new#call', as: :new_change_password
        post Stormpath::Rails.config.web.change_password.uri => 'change_password/create#call', as: :change_password
      end

      # ME
      if Stormpath::Rails.config.web.me.enabled
        get Stormpath::Rails.config.web.me.uri => 'profile/show#call'
      end

      # OAUTH2
      if Stormpath::Rails.config.web.oauth2.enabled
        get Stormpath::Rails.config.web.oauth2.uri => 'oauth2/new#call'
        post Stormpath::Rails.config.web.oauth2.uri => 'oauth2/create#call'
      end

      # VERIFY EMAIL
      if Stormpath::Rails.config.web.verify_email.enabled
        get Stormpath::Rails.config.web.verify_email.uri => 'verify_email/show#call'
        post Stormpath::Rails.config.web.verify_email.uri => 'verify_email/create#call', as: :verify_email
      end
    end
  end
end
