NearbyThis::Application.routes.draw do
  
  devise_for :users
  resources :users, :locations
  resources :events do
    member do
      get :ical
    end
  end

  #------------------------ Consumer --------------------------
  root :to => "places#index"
  get "start" => "places#start", :as => :places_start
  get "/" => "places#index", :as => :places
  get "search" => "places#search"
  get "details/:reference" => "places#details", :as => :location_details
  post "recent_tweeters" => "places#recent_tweeters", :as => :recent_tweeters

  #----------------------------- Mobile ---------------------------
  get "/mobile"             => "mobile#index",  :as => :mobile_index
  get "/mobile/list"        => "mobile#list",   :as => :mobile_list
  get "/mobile/detail/:id"  => "mobile#detail", :as => :mobile_detail
  get "/mobile/deals"       => "mobile#deals",  :as => :mobile_deals
  get "/mobile/events"      => "mobile#events", :as => :mobile_events
  get "/mobile/event/:id"   => "mobile#event",  :as => :mobile_event
  get "/mobile/city/:city"  => "mobile#city",  :as => :mobile_city

  #---------------------------- Iphone ----------------------------
  get "/iphone" => "iphone#index"
  get "/iphone_details" => "iphone#iphone_details"
  get "/iphone_delete_place/:reference" => "iphone#delete_place"
  get "/iphone_deals" => "iphone#deals"
  get "/iphone_events" => "iphone#events"

  #------------------------------ API ==----------------------------
  namespace :api do
    get "/" => "api#index"
    get "/places" => "places#index", :as => :places
    get "/places/:reference" => "places#show", :as => :place
  end
  
    
end
