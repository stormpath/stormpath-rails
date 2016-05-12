Rails.application.routes.draw do
  constraints Stormpath::Rails::RoutingConstraint do
    # LOGIN
    if Stormpath::Rails.config.login.enabled
      get  Stormpath::Rails.config.login.uri => 'stormpath/rails/login#new',    as: 'sign_in'
      post Stormpath::Rails.config.login.uri => 'stormpath/rails/login#create', as: 'login_user'
    end

    # LOGOUT
    if Stormpath::Rails.config.logout.enabled
      post Stormpath::Rails.config.logout.uri => 'stormpath/rails/logout#create', as: 'sign_out'
    end

    # FORGOT PASSWORD
    if Stormpath::Rails.config.forgot_password.enabled
      get  Stormpath::Rails.config.forgot_password.uri => 'stormpath/rails/passwords#forgot', as: 'forgot'
      post Stormpath::Rails.config.forgot_password.uri => 'stormpath/rails/passwords#forgot_send', as: 'forgot_send'
    end

    resource :users, controller: 'stormpath/rails/users', only: :create
    get    Stormpath::Rails.config.register.uri => 'stormpath/rails/users#new', as: 'sign_up'
    get    Stormpath::Rails.config.verify_email.uri => 'stormpath/rails/users#verify', as: 'verify'

    get    Stormpath::Rails.config.id_site.uri => 'stormpath/rails/login#redirect', as: 'redirect'
    get    '/omniauth_login' => 'stormpath/rails/omniauth#create', as: 'omniauth_login'

    get    '/forgot/change' => 'stormpath/rails/passwords#forgot_change', as: 'forgot_change'
    post   '/forgot/change/:account_url' => 'stormpath/rails/passwords#forgot_update', as: 'forgot_update'

    post   '/register' => 'stormpath/rails/users#create', as: 'register_user'
    get    '/me' => 'stormpath/rails/users#profile', as: 'user_profile'
  end
end
