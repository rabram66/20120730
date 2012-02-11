NearbyThis::Application.routes.draw do
  
  devise_for :users
  resources :users, :events, :locations

  #------------------------ Consumer --------------------------
  root :to => "places#index"
  get "/" => "places#index", :as => :places
  get "search" => "places#search"
  get "details/:reference" => "places#details", :as => :location_details
  post "recent_tweeters" => "places#recent_tweeters", :as => :recent_tweeters

  #------------------------Website-----------------------------
  # post "locations/index"
  # get "/signup" => "locations#new"
  # get "locations/new" => "locations#new"
  # get "/delete_place/:id" => "locations#delete_place"
  # get "/xml_res" => "locations#xml_res"  

  #----------------------------- Mobile ---------------------------
  get "/mobile"            => "mobile#index",  :as => :mobile_index
  get "/mobile/list"       => "mobile#list",   :as => :mobile_list
  get "/mobile/detail/:id" => "mobile#detail", :as => :mobile_detail
  get "/mobile/deals"      => "mobile#deals",  :as => :mobile_deals
  get "/mobile/events"     => "mobile#events", :as => :mobile_events
  get "/mobile/event/:id"  => "mobile#event",  :as => :mobile_event

  #---------------------------- Iphone ----------------------------
  get "/iphone" => "iphone#index"
  get "/iphone_details" => "iphone#iphone_details"
  get "/iphone_delete_place/:reference" => "iphone#delete_place"
  get "/iphone_deals" => "iphone#deals"
  get "/iphone_events" => "iphone#events"

  #------------------------------ API ==----------------------------
  namespace :api do
    get "/" => "api#index"
    # resources :places, :only => [:index, :show]
    get "/places" => "places#index", :as => :places
    get "/places/:reference" => "places#show", :as => :place
  end
  
    
end
