LocationDB::Application.routes.draw do
  devise_for :users
  resources :users, :events, :advertises, :newstuffs, :locations

  #------------------------Website-----------------------------
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
  get "/load_business/:address" => "locations#load_business"
  get "/load_deals" => "locations#load_deals"
  get "/load_page" => "locations#load_page"  
  get "/xml_res" => "locations#xml_res"  
  root :to => "locations#index"
  
  #---------------------------- Iphone ----------------------------
  get "/iphone" => "iphone#iphone"
  get "/iphone_details" => "iphone#iphone_details"
  get "/iphone_delete_place/:reference" => "iphone#delete_place"
  get "/iphone_deals" => "iphone#deals"
  get "/iphone_events" => "iphone#events"
  
end
