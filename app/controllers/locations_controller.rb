include Geokit::Geocoders
require 'json'
require 'open-uri'

class LocationsController < ApplicationController
  
  respond_to :html, :xml, :json, :js
  
  RADIUS = '3000'  
  DEFAULT_LOCATION = 'Atlanta, GA'
  before_filter :authenticate_user!, :only => [:new, :edit, :create, :update]
  
  def index
    types = params[:types].blank? ? get_types("Eat/Drink") : get_types(params[:types])
    @search = params[:search]
    unless @search.blank?
      @latlng = Geocoder.coordinates(@search)  
      session[:search] = @latlng unless @latlng.blank?
    else      
      if session[:search].blank?
        current_location = MultiGeocoder.geocode(request.remote_ip).to_json
        if !current_location["Latitude"].blank? && !current_location["Longitude"].blank?
          @latlng = [current_location["Latitude"], current_location["Longitude"]]        
        end
      end
    end
    
    @latlng = Geocoder.coordinates(DEFAULT_LOCATION) if @latlng.blank? &&  session[:search].blank?    
    coordinates = @latlng.blank? ? session[:search] : @latlng
    begin
      @near_your_locations = HTTParty.get("https://maps.googleapis.com/maps/api/place/search/json?location=#{coordinates.join(',')}&types=#{types}&radius=#{RADIUS}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")
    rescue
		end
    
    begin
	    @locations = Location.near(coordinates, 300).where(:general_type => params[:types])   
		rescue
		end
    
    #get deals from yipit
#    begin
#      deals = RestClient.get "http://api.yipit.com/v1/deals/?key=zZnf9zms8Kxp6BPE&lat=#{coordinates[0]}&lon=#{coordinates[1]}"
#      deals = Hash.from_xml(deals).to_json
#      @deals = ActiveSupport::JSON.decode(deals)
#    rescue
#		end
    
    begin     
    @events = Event.near(coordinates, 300)    
    rescue
		end
  end
  
  # TODO
  def search
   @latlng = [params[:latitude], params[:longitude]]
    session[:search] = @latlng
    redirect_to locations_path
  end
  
  def near_location
    types = get_types("Eat/Drink")
    @latlng = [params[:latitude], params[:longitude]]
    session[:search] = @latlng
    @near_your_locations = HTTParty.get("https://maps.googleapis.com/maps/api/place/search/json?location=#{session[:search].join(',')}&types=#{types}&radius=#{RADIUS}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")
    render :partial => "near_your_locations",  :layout => false
  end
 
  def details
    reference = params[:reference]   
    @search = Rails.cache.read("searchtext")
    @details = get_place_response(reference)
    
    @location = Location.find_by_reference(reference)        
    
    @advertise = get_logo(@details, @location)
    
    @origin_address = params[:address]
    
    unless @location.blank?
      @last_tweet = get_last_tweet(@location.twitter_name)    
      @last_post = get_last_post(@location)
      @user_saying = get_tweet_search(@location.twitter_name)
    end    
  end
  
  def delete_place    
    myarray = {:reference => params[:id]}
    myarray = ActiveSupport::JSON.encode(myarray) 
    result = RestClient.post "https://maps.googleapis.com/maps/api/place/delete/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc", myarray, :content_type => :json, :accept => :json
    res = ActiveSupport::JSON.decode(result)
    
    if res['status'].eql?("OK")
      render :text => "1"
    else
      render :text => "2"
    end
  end
 
   
  def show
    @location = Location.find(params[:id])
    
    @feed = get_facebook_feed(@location.facebook_page_id)
    @tweet = get_twitter_feed(@location.twitter_name)
    
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/new
  # GET /locations/new.xml
  def new
    @location = Location.new
    @pages = {}
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end
  
  def load_page  
    results = RestClient.get "https://graph.facebook.com/search?q=#{params[:q].gsub(" ", "+")}&limit=5&type=page"
    res = ActiveSupport::JSON.decode(results)    
    render :json => res['data']
  end
  
  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
    @pages = [{id: @location.id, name: @location.name}]
  end

  # POST /locations
  # POST /locations.xml
  def create
    @location = Location.new(params[:location])    
    # transale address into lat/long
    lat, long = Geocoder.coordinates(@location.full_address)     
    
    response = get_place_report(params[:location], long, lat)
    @location.reference = response["reference"]
    @location.general_type = get_general_type(params[:location][:types])
    respond_to do |format|
      if @location.save 
        format.html { redirect_to(@location, :notice => 'Location was successfully created.') }
        format.xml  { render :xml => @location, :status => :created, :location => @location }        
      else
        @pages = {}
        format.html { render :action => "new" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /locations/1
  # PUT /locations/1.xml
  def update
    @location = Location.find(params[:id])
    
    full_address = "#{params[:location][:address]} #{params[:location][:city]}, #{params[:location][:state]}"
    # transale address into lat/long
    lat, long = Geocoder.coordinates(full_address)    
    response = get_place_report(params[:location], long, lat)    
    @location.reference = response["reference"] unless response["reference"].blank?
    @location.general_type = get_general_type(params[:location][:types]) unless params[:location][:types].blank?
    respond_to do |format|
      if @location.update_attributes(params[:location])
        format.html { redirect_to(@location, :notice => 'Location was successfully updated.') }
        format.xml  { head :ok }
      else
        @pages = [{id: @location.id, name: @location.name}]
        format.html { render :action => "edit" }
        format.xml  { render :xml => @location.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /locations/1
  # DELETE /locations/1.xml
  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    respond_to do |format|
      format.html { redirect_to(locations_url) }
      format.xml  { head :ok }
    end
  end
  
  private
  
  def get_logo(details, location)   
    adv = nil
    unless location.blank?      
      adv = Advertise.find_by_business_type(location.types)
    else      
      details['result']['types'].each do |type|
        adv = Advertise.find_by_business_type(type)
        return adv unless adv.blank?
      end
    end
    return adv
  end
  

  def types(general_type)
    results = ""
    if general_type.eql?("Eat/Drink")
      results = eat_drink
    elsif general_type.eql?("Relax/Care")
      results = relax_care
    elsif general_type.eql?("Shop/Find")
      results = shop_find
    end
    results
  end
    
  def get_general_type(type)    
    return "Eat/Drink" if eat_drink.include?(type)
    return "Relax/Care" if relax_care.include?(type)
    return "Shop/Find" if shop_find.include?(type)
  end
  
  def get_facebook_feed(facebook_page_id)
    begin
      # convert real name to id
      res_page = RestClient.get "https://graph.facebook.com/#{facebook_page_id}"
      result_page = ActiveSupport::JSON.decode(res_page) 
      
      facebook_link = "http://www.facebook.com/feeds/page.php?id=#{result_page["id"]}&format=json"
      res = RestClient.get facebook_link
      return ActiveSupport::JSON.decode(res)
    rescue
    end    
  end
  
  def get_twitter_feed(twitter_name)
    begin
      twitter_link = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{twitter_name}"
      timeline = RestClient.get twitter_link
      return ActiveSupport::JSON.decode(timeline)
    rescue
    end
  end
  
  def get_place_report(location, long, lat)    
    myarray = {:location => {:lat => lat.to_f, :lng => long.to_f},
      :accuracy => 50, :name => location[:name], 
      :types => [location[:types]], :language => "en-AU"}
    json_string = myarray.to_json()    
    res = RestClient.post "https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc", json_string, :content_type => :json, :accept => :json    
    ActiveSupport::JSON.decode(res)
  end
  
  def get_place_response(reference)
    HTTParty.get("https://maps.googleapis.com/maps/api/place/details/json?reference=#{reference}&sensor=true&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")
  end
  
  def get_last_post(location)    
    unless location.facebook_page_id.blank?
      # convert real name to id  
      id = location.facebook_page_id
      if is_real_name(location.facebook_page_id)
        res_page = RestClient.get "https://graph.facebook.com/#{location.facebook_page_id}"
        result_page = ActiveSupport::JSON.decode(res_page) 
        id = result_page["id"]
      end
      
      facebook_link = "http://www.facebook.com/feeds/page.php?id=#{id}&format=json"
      res = RestClient.get facebook_link
      results = ActiveSupport::JSON.decode(res)
      
      return results["entries"].first["title"] unless results["entries"].blank?
    end
  end
  
  def get_last_tweet(user_name)    
    timeline = RestClient.get "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{user_name}&count=1"
    ActiveSupport::JSON.decode(timeline)    
  end
  
  def get_tweet_search(bussiness_name) 
    tweet = RestClient.get  "http://search.twitter.com/search.json?q=@#{bussiness_name.gsub(" ", "+")}&count=10"    
    ActiveSupport::JSON.decode(tweet)    
  end
  
  def is_real_name(name)
    name.to_i == 0? true : false
  end
  
  def eat_drink
    return ["bakery", "bar", "cafe", "food", "meal takeaway", "restaurant"]
  end
  
  def relax_care
    ["amusement park", "aquarium", "art gallery", "beauty salon", "bowling alley",
      "casino", "gym", "hair care", "health", "movie theater", "museum", "night club", "park", "spa", "zoo"]
  end
  
  def shop_find
    ["atm", "bank", "bicycle store", "book store", "bus station", "clothing store", "convenience store" ,
      "department store", "electronics store", "establishment", "florist", "gas station", "grocery or supermarket",
      "hardware store", "home goods store", "jewelry store", "library", "liquor store", "locksmith", "pet store",
      "pharmacy", "shoe store", "shopping mall", "store"]
  end
  
  def get_types(types)
    results = ""
    if types.eql?("Eat/Drink")
      results = "bakery%7Cbar%7Ccafe%7Cfood%7Cmeal_takeaway%7Crestaurant"
    elsif types.eql?("Relax/Care")
      results = "amusement_park%7Caquarium%7Cart_gallery%7Cbeauty_salon%7Cbowling_alley," +
        "casino%7Cgym%7Chair_care%7Chealth%7Cmovie_theater%7Cmuseum%7Cnight_club%7Cpark%7Cspa%7Czoo"
    elsif types.eql?("Shop/Find")
      results = "atm%7Cbank%7Cbicycle_store%7Cbook_store%7Cbus_station%7Cclothing_store%7Cconvenience_store," +
        "department_store%7Celectronics_store%7Cestablishment%7Cflorist%7Cgas_station%7Cgrocery_or_supermarket%7C" +
        "hardware_store%7Chome_goods_store%7Cjewelry_store%7Clibrary%7Cliquor_store%7Clocksmith%7Cpet_store%7C" +
        "pharmacy%7Cshoe_store%7Cshopping_mall%7Cstore"
    end
    results
  end
  
end 

