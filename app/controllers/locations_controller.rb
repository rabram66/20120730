include Geokit::Geocoders
class LocationsController < ApplicationController
  respond_to :html, :xml, :json, :js
  
  RADIUS = '3000'  
  DEFAULT_LOCATION = 'Atlanta, GA'
  
  
  def index
    types = get_types("Eat/Drink")
    @search = params[:search]
    unless @search.blank?
      @latlng = Geocoder.coordinates(@search)  
      session[:search] = @latlng unless @latlng.blank?
    else      
      if session[:search].blank?
        current_location = ActiveSupport::JSON.decode(MultiGeocoder.geocode(request.remote_ip).to_s)
        if !current_location["Latitude"].blank? && !current_location["Longitude"].blank?
          @latlng = [current_location["Latitude"], current_location["Longitude"]]        
        end
      end
    end
    
    @latlng = Geocoder.coordinates(DEFAULT_LOCATION) if @latlng.blank? &&  session[:search].blank?    
    coordinates = @latlng.blank? ? session[:search].join(',') : @latlng.join(',')
    
    @near_your_locations = HTTParty.get("https://maps.googleapis.com/maps/api/place/search/json?location=#{coordinates}&types=#{types}&radius=#{RADIUS}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")
    @locations = Location.where("reference is not null")
  end
  
  # TODO
  def search
    @latlng = [params[:latitude], params[:longitude]]    
    @locations = Location.where("reference is not null")
    render :partial => "locations"
  end
  
  def near_location
    types = get_types("Eat/Drink")
    @latlng = [params[:latitude], params[:longitude]]
    session[:search] = @latlng
    @near_your_locations = HTTParty.get("https://maps.googleapis.com/maps/api/place/search/json?location=#{session[:search].join(',')}&types=#{types}&radius=#{RADIUS}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")
    render :partial => "near_your_locations"
  end
 
  def details
    reference = params[:reference]   
    @search = Rails.cache.read("searchtext")
    @details = get_place_response(reference)
    
    @location = Location.find_by_reference(reference)    
    unless @location.blank?
      @last_tweet = get_last_tweet(@location.twitter_name)    
      @last_post = get_last_post(@location)
      @user_saying = get_tweet_search(@location.twitter_name)
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

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @location }
    end
  end

  # GET /locations/1/edit
  def edit
    @location = Location.find(params[:id])
  end

  # POST /locations
  # POST /locations.xml
  def create
    @location = Location.new(params[:location])    

    # transale address into lat/long
    lat, long = Geocoder.coordinates(@location.full_address)     
    
    response = get_place_report(params[:location], long, lat)
    @location.reference = response["reference"]
      
    respond_to do |format|
      if @location.save 
        format.html { redirect_to(@location, :notice => 'Location was successfully created.') }
        format.xml  { render :xml => @location, :status => :created, :location => @location }        
      else
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
    
    
    @location.reference = response["reference"]

    respond_to do |format|
      if @location.update_attributes(params[:location])
        format.html { redirect_to(@location, :notice => 'Location was successfully updated.') }
        format.xml  { head :ok }
      else
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
  
end 

