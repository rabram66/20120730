include Geokit::Geocoders
require 'json'
require 'open-uri'

class LocationsController < ApplicationController
  before_filter :role, :except => [:load_deals, :details, :index, :delete_place, :save_place, :iphone, :xml_res, :load_business]
  before_filter :redirect_mobile_request
  
  respond_to :html, :xml, :json, :js
  
  RADIUS = '750'  
  DEFAULT_LOCATION = [33.7489954, -84.3879824] # Atlanta, GA

  before_filter :authenticate_user!, :only => [:new, :edit, :create, :update]
  

  def index

    # TODO: Clean up
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
  
    # TODO: Clean up
    @latlng = DEFAULT_LOCATION if @latlng.blank? && session[:search].blank?    
    coordinates = @latlng.blank? ? session[:search] : @latlng  
    if coordinates.blank?
      @latlng = [33.7489954, -84.3879824] # DEFAULT_LOCATION = 'Atlanta, GA' 
      coordinates = @latlng
    end
    cookies[:address] = { :value => coordinates, :expires => 1.year.from_now }
    
    category = params[:types].blank? ? LocationCategory::EatDrink : LocationCategory.find_by_name(params[:types])
    @locations = Location.near(coordinates, 2, :order => :distance).where(:general_type => category.name ) 
    @locations.reject! {|l| l.reference.nil? } # TODO: Remove this once reference can be gauranteed

    @places = Place.find_by_geocode(coordinates, category.types)
    remove_duplicate_places unless @places.empty? || @locations.empty?
    @events = Event.near(coordinates, 2)
  end
  
  # TODO
  def search
    @latlng = [params[:latitude].to_f, params[:longitude].to_f]
    session[:search] = @latlng
    redirect_to locations_path
  end
  
  def details
    @ad_tracking = AdTracking.new
    @ad_tracking.ip_address = request.ip
    @ad_tracking.save
    
    reference = params[:reference]
    @location = Location.find_by_reference(reference) || Place.find_by_reference(reference)
    @origin_address = params[:address]
    
    @advertise = get_logo(@location)

    if Location === @location
      @last_tweet = @location.twitter_status    
      @last_post = @location.facebook_status      
      @user_saying = @location.twitter_mentions(8)
    end

    @ad_tracking.business_name = @location.name
    @ad_tracking.advertise_id = @advertise.id unless @advertise.blank?
    @ad_tracking.save
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
  
  # Ajax load of deals onto index page
  def load_deals
    @deals = Deal.find_by_geocode( geocode_from_cookie )
    render :partial => 'deals', :layout => false
  end
   
  # Used by location owner or admin ("details" provides the public view)
  def show
    @location = Location.find(params[:id])
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

    # translate address into lat/long
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
    # translate address into lat/long
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

  def geocode_from_cookie
    cookies[:address] ? cookies[:address].split("&") : DEFAULT_LOCATION
  end
  
  def redirect_mobile_request
    redirect_to :controller => 'mobile', :action => 'index' if is_mobile_device?
  end
  
  def remove_duplicate_places
    @places.reject! do |place| 
      exclude_place? place
    end
  end

  def exclude_place?(place)
    @locations.any? do |location| 
      place.name == location.name ||
      (place.vicinity && place.vicinity.include?(location.address)) ||
      place.geo_code == location.geo_code
    end
  end
  
  def get_logo(location)   
    adv = nil
    if Location === location      
      adv = Advertise.where("address_name like ? and business_name like ?", "%#{location.city}, #{location.state}%", "%#{location.name}%").first();      
      adv = Advertise.where("business_name like ? ", "%#{location.name}%").first() if adv.blank?
      adv = Advertise.where("address_name like ?", "%#{location.city}, #{location.state}%").first() if adv.blank?
      adv = Advertise.where("business_type = '#{location.types}'").first() if adv.blank?
    else
      if location.vicinity && location.name
        # Some places only have city
        if location.vicinity.include? ','
          add, city = location.vicinity.split(",")
        else
          add = ''
          city = location.vicinity
        end
        adv = Advertise.where("(address_name like ? or address_name like ? ) and business_name like ? ", "%#{city.strip}%", "%#{add.strip}%", "%#{location.name}%").first()
        adv = Advertise.where("business_name like ? ", "%#{location.name}%").first() if adv.blank?          
      end      
    end
    return adv
  end
  

  def get_general_type(type)    
    return "Eat/Drink" if eat_drink.include?(type)
    return "Relax/Care" if relax_care.include?(type)
    return "Shop/Find" if shop_find.include?(type)
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
  
end 

