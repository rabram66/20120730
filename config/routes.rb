LocationDB::Application.routes.draw do
  resources :newstuffs
  resources :locations

  post "locations/index"

  root :to => "locations#index"
  
  resources :locations
  get "/signup" => "locations#new"
  get  "locations" => "locations#viewresults"
  get "locations/new" => "locations#new"
  get "details/:reference" => "locations#details", :as => :locations_details
  get "details/:id" => "locations#details", :as => :locations_details
  
  
  
end
