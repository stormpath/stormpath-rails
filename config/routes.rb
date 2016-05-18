Rails.application.routes.draw do
  constraints Stormpath::Rails::RoutingConstraint do
    # LOGIN
    if Stormpath::Rails.config.web.login.enabled
      get  Stormpath::Rails.config.web.login.uri => 'stormpath/rails/login#new',    as: 'sign_in'
      post Stormpath::Rails.config.web.login.uri => 'stormpath/rails/login#create', as: 'login_user'
    end

    # LOGOUT
    if Stormpath::Rails.config.web.logout.enabled
      post Stormpath::Rails.config.web.logout.uri => 'stormpath/rails/logout#create', as: 'sign_out'
    end

    # FORGOT PASSWORD
    if Stormpath::Rails.config.web.forgot_password.enabled
      get  Stormpath::Rails.config.web.forgot_password.uri => 'stormpath/rails/forgot_passwords#new', as: 'forgot'
      post Stormpath::Rails.config.web.forgot_password.uri => 'stormpath/rails/forgot_passwords#create', as: 'forgot_send'
    end

    # CHANGE PASSWORD
    if Stormpath::Rails.config.web.change_password.enabled
      get  Stormpath::Rails.config.web.change_password.uri => 'stormpath/rails/change_passwords#new', as: 'forgot_change'
      post Stormpath::Rails.config.web.change_password.uri => 'stormpath/rails/change_passwords#create', as: 'forgot_update'
    end

    resource :users, controller: 'stormpath/rails/users', only: :create
    get    Stormpath::Rails.config.web.register.uri => 'stormpath/rails/users#new', as: 'sign_up'
    get    Stormpath::Rails.config.web.verify_email.uri => 'stormpath/rails/users#verify', as: 'verify'

    if Stormpath::Rails.config.web.id_site.enabled
      get Stormpath::Rails.config.web.id_site.uri => 'stormpath/rails/login#redirect', as: 'redirect'
    end

    get '/omniauth_login' => 'stormpath/rails/omniauth#create', as: 'omniauth_login'

    post   '/register' => 'stormpath/rails/users#create', as: 'register_user'
    get    '/me' => 'stormpath/rails/users#profile', as: 'user_profile'
  end
end
