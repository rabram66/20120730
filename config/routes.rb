LocationDB::Application.routes.draw do
  resources :events

  devise_for :users

  resources :advertises

  resources :newstuffs
  resources :locations

  post "locations/index"
  get "near_location" => "locations#near_location"
  get "search" => "locations#search"
  get "/signup" => "locations#new"
  get  "locations" => "locations#viewresults"
  get "locations/new" => "locations#new"
  get "details/:reference" => "locations#details", :as => :locations_details
  get "details/:id" => "locations#details", :as => :locations_details  
  get "/delete_place/:id" => "locations#delete_place"
  root :to => "locations#index"  
end
