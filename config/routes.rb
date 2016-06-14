Rails.application.routes.draw do
  constraints Stormpath::Rails::RoutingConstraint do
    scope module: 'stormpath/rails' do
      # REGISTER
      if Stormpath::Rails.config.web.register.enabled
        get Stormpath::Rails.config.web.register.uri => 'register#new', as: :new_register
        post Stormpath::Rails.config.web.register.uri => 'register#create', as: :register
      end

      # LOGIN
      if Stormpath::Rails.config.web.login.enabled
        get Stormpath::Rails.config.web.login.uri => 'login#new', as: :new_login
        post Stormpath::Rails.config.web.login.uri => 'login#create', as: :login
      end

      # LOGOUT
      if Stormpath::Rails.config.web.logout.enabled
        post Stormpath::Rails.config.web.logout.uri => 'logout#create', as: :logout
      end

      # FORGOT PASSWORD
      if Stormpath::Rails.config.web.forgot_password.enabled
        get Stormpath::Rails.config.web.forgot_password.uri => 'forgot_passwords#new', as: :new_forgot_password
        post Stormpath::Rails.config.web.forgot_password.uri => 'forgot_passwords#create', as: :forgot_password
      end

      # CHANGE PASSWORD
      if Stormpath::Rails.config.web.change_password.enabled
        get Stormpath::Rails.config.web.change_password.uri => 'change_passwords#new', as: :new_change_password
        post Stormpath::Rails.config.web.change_password.uri => 'change_passwords#create', as: :change_password
      end

      # ME
      if Stormpath::Rails.config.web.me.enabled
        get Stormpath::Rails.config.web.me.uri => 'profile#show'
      end

      # OAUTH2
      if Stormpath::Rails.config.web.oauth2.enabled
        get Stormpath::Rails.config.web.oauth2.uri => 'oauth2#new'
        post Stormpath::Rails.config.web.oauth2.uri => 'oauth2#create'
      end
      # if Stormpath::Rails.config.web.id_site.enabled
      #   get Stormpath::Rails.config.web.id_site.uri => 'stormpath/rails/login#redirect'
      # end
      # get '/omniauth_login' => 'stormpath/rails/omniauth#create', as: 'omniauth_login'
      # get   Stormpath::Rails.config.web.verify_email.uri => 'stormpath/rails/register#verify', as: 'verify'
      # post   '/register' => 'stormpath/rails/register#create', as: 'register_user'
      # get   '/me' => 'stormpath/rails/register#profile', as: 'user_profile'
    end
  end
end
