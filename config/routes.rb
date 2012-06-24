NearbyThis::Application.routes.draw do
  
  resources :deals do
    resources :deal_locations
  end

  devise_for :users
  resources :users, :locations
  resources :events, :except => :show

  #------------------------ Consumer --------------------------
  root :to => "places#index"
  get "start" => "places#start", :as => :places_start
  get "/" => "places#index", :as => :places
  get "search" => "places#search"
  get "details/:reference" => "places#details", :as => :location_details
  get "events/:id" => "places#event", :as => :event_detail
  get "events/:id/ical" => "places#ical", :as => :ical_event
  post "favorite/:reference" => "places#favorite", :as => :location_favorite

  # -------------------------- Superflous pages --------------------
  get "/about" => 'places#about'
  get "/advertise" => 'places#advertise'
  get "/press" => 'places#press'

  #----------------------------- Mobile ---------------------------
  get "/mobile"             => "mobile#index",  :as => :mobile_index
  get "/mobile/list"        => "mobile#list",   :as => :mobile_list
  get "/mobile/detail/:id"  => "mobile#detail", :as => :mobile_detail
  get "/mobile/deals"       => "mobile#deals",  :as => :mobile_deals
  get "/mobile/events"      => "mobile#events", :as => :mobile_events
  get "/mobile/event/:id"   => "mobile#event",  :as => :mobile_event
  get "/mobile/city/:city"  => "mobile#city",  :as => :mobile_city

  #----------------------------- Power24 ---------------------------
  get "/power24/index"       => "power24#index",  :as => :power24_index
  get "/power24"             => "power24#events"
  get "/power24/list"        => "power24#list",   :as => :power24_list
  get "/power24/detail/:id"  => "power24#detail", :as => :power24_detail
  get "/power24/deals"       => "power24#deals",  :as => :power24_deals
  get "/power24/events"      => "power24#events", :as => :power24_events
  get "/power24/event/:id"   => "power24#event",  :as => :power24_event

  #------------------------------ API ------------------------------
  namespace :api do
    get "/"                  => "api#index"
    get "/places"            => "places#index", :as => :places
    get "/places/:reference" => "places#show",  :as => :place
    get "/events"            => "events#index", :as => :events
    get "/events/:id"        => "events#show",  :as => :event
    get "/deals"             => "deals#index",  :as => :deals
    get "/twitter_profile"   => "api#twitter_profile", :as => :twitter_profile
  end

  # ---------------------------- Backend -----------------------------
  match '/dashboard' => 'pages#dashboard', :as => :user_root
end
