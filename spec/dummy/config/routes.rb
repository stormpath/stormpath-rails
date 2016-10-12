Rails.application.routes.draw do
  devise_for :users
  stormpath_rails_routes
  root to: 'static_pages#index'
  get 'about', to: 'static_pages#about'
  get 'my_profile', to: 'profiles#show'
end
