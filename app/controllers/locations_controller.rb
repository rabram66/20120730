include Geokit::Geocoders
require 'json'
require 'open-uri'

class LocationsController < ApplicationController
  before_filter :role, :except => [:load_deals, :details, :index,:delete_place, :save_place, :iphone, :xml_res, :load_business]
  before_filter :redirect_mobile_request
  
  respond_to :html, :xml, :json, :js
  
  RADIUS = '750'  
  DEFAULT_LOCATION = 'Atlanta, GA' 
  before_filter :authenticate_user!, :only => [:new, :edit, :create, :update]
  
  def test_heroku
    
  end

  def index
    types = params[:types].blank? ? get_types("Eat/Drink") : get_types(params[:types])
    @search = params[:search] unless params[:search].blank?
    unless @search.blank?      
      @latlng = Geocoder.coordinates(@search)
      session[:search] = @latlng unless @latlng.blank?
    else      
      if session[:search].blank?
        current_location = MultiGeocoder.geocode(request.remote_ip).to_json
        if !current_location["Latitude"].blank? && !current_location["Longitude"].blank?
          @latlng = [current_location["Latitude"].to_f, current_location["Longitude"].to_f]        
        end
      end
    end
  
    @latlng = Geocoder.coordinates(DEFAULT_LOCATION) if @latlng.blank? &&  session[:search].blank?    
    coordinates = @latlng.blank? ? session[:search] : @latlng  
    if coordinates.blank?
      @latlng = [33.7489954, -84.3879824] # DEFAULT_LOCATION = 'Atlanta, GA' 
      coordinates = @latlng
    end
    cookies[:address] = { :value => coordinates, :expires => 1.year.from_now }
  
    begin
      @near_your_locations = HTTParty.get("https://maps.googleapis.com/maps/api/place/search/json?location=#{coordinates.join(',')}&types=#{types}&radius=#{RADIUS}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")
    rescue
    end
  
    begin
      @locations = Location.near(coordinates, 2, :order => :distance).where(:general_type => params[:types].blank? ? "Eat/Drink" : params[:types] ) 
    rescue
    end
    
    # Remove duplicates from near_your_locations
    remove_duplicate_locations
  
    begin     
      @events = Event.near(coordinates, 2)
    rescue
    end
  end
  
  # TODO
  def search
    @latlng = [params[:latitude].to_f, params[:longitude].to_f]
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
    @details = get_place_response(reference)
    
    @location = Location.find_by_reference(reference)        
    @origin_address = params[:address]    
    
    @advertise = get_logo(@details, @location)
    
    
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
  
  def save_place
    cookies[:address] = { :value => params[:address], :expires => 1.year.from_now }    
    unless cookies[:address].blank?
      render :text => "1"
    else
      render :text => "2"
    end
  end
  
  def load_business
    address = params[:address]    
    category = params[:category]
    coordinates= Geocoder.coordinates(address)  
          
    xml_res = Array.new
    
    begin
      near_your_locations = HTTParty.get("https://maps.googleapis.com/maps/api/place/search/json?location=#{coordinates.join(',')}&types=#{category}&radius=#{RADIUS}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")
      near_your_locations['results'].each do |location|
        xml_res += [location['name']]
      end
    rescue
    end
    
    begin      
      locations = Location.near(coordinates, 2)
      locations.each do |location|
        xml_res += [location.name]
      end
    rescue
    end
    
    @results = xml_res.sort    
    render :partial => 'business_name', :layout => false, :results => @results
  end
  
  def load_deals
    #get deals from yipit
    begin
      lat, lon = cookies[:address].split("&")
      deals = RestClient.get "http://api.yipit.com/v1/deals/?key=zZnf9zms8Kxp6BPE&lat=#{lat}&lon=#{lon}"
      deals = Hash.from_xml(deals).to_json
      @deals = ActiveSupport::JSON.decode(deals)
    rescue
		end
    
    render :partial => 'deals', :layout => false
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
    @location.types = "grocery_or_supermarket" if params[:location][:types].eql?("grocery")
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
  
  def redirect_mobile_request
    redirect_to :controller => 'mobile', :action => 'index' if is_mobile_device?
  end
  
  def remove_duplicate_locations
    if @near_your_locations
      @near_your_locations['results'].each_with_index do |place, ndx|
        @near_your_locations['results'][ndx] = nil if exclude_place?(place)
      end
      @near_your_locations['results'].compact!
    end
  end
  
  def exclude_place?(place)
    # Exclude the place if the name is blank, 
    # or there is a place with the same name, address, or lat-lng in @locations
    return true if place['name'].blank?
    return false if @locations.nil?
    @locations.any? do |location|
      ( place['name'] == location.name ) ||
      ( place['vicinity'] && place['vicinity'].include?(location.address) ) ||
      ( place['geometry']['location']['lat'] == location.latitude && 
        place['geometry']['location']['lng'] == location.longitude )
    end
  end
  
  def get_logo(details, location)   
    adv = nil
    unless location.blank?      
      adv = Advertise.where("address_name like ? and business_name like ?", "%#{location.city}, #{location.state}%", "%#{location.name}%").first();      
      adv = Advertise.where("business_name like ? ", "%#{location.name}%").first() if adv.blank?
      adv = Advertise.where("address_name like ?", "%#{location.city}, #{location.state}%").first() if adv.blank?
      adv = Advertise.where("business_type = '#{location.types}'").first() if adv.blank?
    else
      loc = details['result']       
      if loc['vicinity'] != nil && loc['name'] != nil
        # Some places only have city
        if loc['vicinity'].include? ','
          add, city = loc['vicinity'].split(",")
        else
          add = ''
          city = loc['vicinity']
        end
        adv = Advertise.where("(address_name like ? or address_name like ? ) and business_name like ? ", "%#{city.strip}%", "%#{add.strip}%", "%#{loc['name']}%").first()
        adv = Advertise.where("business_name like ? ", "%#{loc['name']}%").first() if adv.blank?          
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
    return ["bar", "cafe", "food", "restaurant"]
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
      results = "bar%7Ccafe%7Crestaurant%7Cfood"
    elsif types.eql?("Relax/Care")
      results = "aquarium%7Cart_gallery%7Cbeauty_salon%7Cbowling_alley," +
        "casino%7Cgym%7Cmovie_theater%7Cmuseum%7Cnight_club%7Cpark%7Cspa"
    elsif types.eql?("Shop/Find")
      results = "clothing_store%7Cshoe_store%7Cconvenience_store"
    end
    results
  end
end 

