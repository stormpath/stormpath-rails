Rails.application.routes.draw do
  resource :session, controller: 'stormpath/sessions', only: [:create]
  resource :users, controller: 'stormpath/users', only: :create
  get '/register' => 'stormpath/users#new', as: 'sign_up'
  get '/login' => 'stormpath/sessions#new', as: 'sign_in'
  delete '/sign_out' => 'stormpath/sessions#destroy', as: 'sign_out'
end