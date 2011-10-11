LocationDB::Application.routes.draw do
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
  root :to => "locations#index"  
end
