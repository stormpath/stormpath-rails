Rails.application.routes.draw do
  resource :session, controller: 'stormpath/sessions', only: [:create]
  resource :users, controller: 'stormpath/users', only: :create
  get '/sign_up' => 'stormpath/users#new', as: 'sign_up'
  get '/sign_in' => 'stormpath/sessions#new', as: 'sign_in'
end