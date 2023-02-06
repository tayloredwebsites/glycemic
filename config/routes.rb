Rails.application.routes.draw do
  resources :food_nutrients #  do  # , except: %i[index]
  get '/nutrients_of_food/:food_id', to: 'food_nutrients#nutrients_of_food'
  # match '/food_nutrients/:id' => 'food_nutrients#destroy', :via => :delete, as: :destroy_food_nutrient # to add the missing destroy route

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
