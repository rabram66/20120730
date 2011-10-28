LocationDB::Application.routes.draw do
  devise_for :users
  resources :users, :events, :advertises, :newstuffs, :locations

  post "locations/index"
  get "near_location" => "locations#near_location"
  get "search" => "locations#search"
  get "/signup" => "locations#new"
  get  "locations" => "locations#viewresults"
  get "locations/new" => "locations#new"
  get "details/:reference" => "locations#details", :as => :locations_details
  get "details/:id" => "locations#details", :as => :locations_details  
  get "/delete_place/:id" => "locations#delete_place"
  match "save_place/:address" => "locations#save_place"
  get "/load_page" => "locations#load_page"  
  get "/iphone" => "locations#iphone"
  get "/xml_res" => "locations#xml_res"
  root :to => "locations#index"  
end
