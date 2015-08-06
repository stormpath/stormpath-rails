Rails.application.routes.draw do
  resource :session, controller: 'stormpath/rails/sessions', only: [:create]
  resource :passwords, controller: 'stormpath/rails/passwords', only: [:new, :create]
  resource :users, controller: 'stormpath/rails/users', only: :create
  get '/register' => 'stormpath/rails/users#new', as: 'sign_up'
  get '/login' => 'stormpath/rails/sessions#new', as: 'sign_in'
  delete '/sign_out' => 'stormpath/rails/sessions#destroy', as: 'sign_out'
end