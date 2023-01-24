Rails.application.routes.draw do
  resources :food_nutrients
  resources :foods
  resources :nutrients
  get 'home/index'
  devise_for :users
  devise_scope :user do
    get '/signout', to: 'devise/sessions#destroy', as: :signout
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#index'
end
