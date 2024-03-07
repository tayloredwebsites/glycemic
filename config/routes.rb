Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  resources :food_nutrients, except: %i[index] do
    member do
      get 'reactivate'
    end
  end
  get '/nutrients_of_food/:food_id', to: 'food_nutrients#nutrients_of_food', as: 'nutrients_of_food'

  resources :foods do
    member do
      get 'reactivate'
    end
  end
  resources :nutrients do
    member do
      get 'reactivate'
    end
  end

  get '/home/index', to: 'home#index'
  get '/home/about', to: 'home#about'
  get '/home/copyright', to: 'home#copyright'

  devise_for :users
  devise_scope :user do
    get '/signout', to: 'devise/sessions#destroy', as: :signout
  end
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  root 'home#index'
end
