Rails.application.routes.draw do
  resources :food_nutrients, except: %i[index] do
    member do
    end
    collection do
    end
  end
  get '/nutrients_of_food/:food_id', to: 'food_nutrients#nutrients_of_food'

  resources :foods do
    member do
      get 'reactivate'
    end
  end
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
