Rails.application.routes.draw do
  resource :users, controller: 'stormpath/users', only: :create
  get '/sign_up' => 'stormpath/users#new', as: 'sign_up'
end