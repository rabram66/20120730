LocationDB::Application.routes.draw do
  
  constraints(NoSubdomain) do
    match '/' => 'pages#landing'
  end

  constraints(Subdomain) do

    devise_for :users
    resources :users, :events, :advertises, :locations

    #------------------------ Consumer --------------------------
    root :to => "places#index"
    get "/" => "places#index", :as => :places
    get "search" => "places#search"
    get "details/:reference" => "places#details", :as => :locations_details
    get "details/:id" => "places#details", :as => :locations_details

    #------------------------Website-----------------------------
    post "locations/index"
    get "/signup" => "locations#new"
    get "locations/new" => "locations#new"
    get "/delete_place/:id" => "locations#delete_place"
    get "/xml_res" => "locations#xml_res"  
  
    #----------------------------- Mobile ---------------------------
    get "/mobile"            => "mobile#index",  :as => :mobile_index
    get "/mobile/list"       => "mobile#list",   :as => :mobile_list
    get "/mobile/detail/:id" => "mobile#detail", :as => :mobile_detail
    get "/mobile/deals"      => "mobile#deals",  :as => :mobile_deals
    get "/mobile/events"     => "mobile#events", :as => :mobile_events
  
    #---------------------------- Iphone ----------------------------
    get "/iphone" => "iphone#index"
    get "/iphone_details" => "iphone#iphone_details"
    get "/iphone_delete_place/:reference" => "iphone#delete_place"
    get "/iphone_deals" => "iphone#deals"
    get "/iphone_events" => "iphone#events"

  end
    
end
