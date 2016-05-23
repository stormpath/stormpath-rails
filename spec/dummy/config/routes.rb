Rails.application.routes.draw do
  root to: 'static_pages#index'
  get 'about', to: 'static_pages#about'
end
