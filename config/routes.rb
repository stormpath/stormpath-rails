Rails.application.routes.draw do
  resource :session, controller: 'stormpath/rails/sessions', only: [:create]
  resource :users, controller: 'stormpath/rails/users', only: :create
  get '/register' => 'stormpath/rails/users#new', as: 'sign_up'
  get '/login' => 'stormpath/rails/sessions#new', as: 'sign_in'
  delete '/sign_out' => 'stormpath/rails/sessions#destroy', as: 'sign_out'
  get '/forgot' => 'stormpath/rails/passwords#forgot', as: 'forgot'
  post '/forgot' => 'stormpath/rails/passwords#forgot_send', as: 'forgot_send'
  get '/forgot/change' => 'stormpath/rails/passwords#forgot_change', as: 'forgot_change'
  post '/forgot/change/:account_url' => 'stormpath/rails/passwords#forgot_update', as: 'forgot_update'
  get '/verify' => 'stormpath/rails/users#verify', as: 'verify'
  get '/redirect' => 'stormpath/rails/sessions#redirect', as: 'redirect'
end