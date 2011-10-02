class LocationsController < ApplicationController
  respond_to :html, :xml, :json, :js
  # GET /locations
  # GET /locations.xml

  def index   
    if params[:search]
      #create session object containg search adddress
 
      Rails.cache.write("searchtext",params[:search])
      @searchtext = params[:search]
   
      @myGeo = HTTParty.get("http://maps.googleapis.com/maps/api/geocode/json?address=#{URI.escape(params[:search])}&sensor=true")
      url = "https://maps.googleapis.com/maps/api/place/search/json?"
      latlng=[@myGeo['results'][0]['geometry']['location']['lat'], @myGeo['results'][0]['geometry']['location']['lng']]  
      thisradius= '1500'
      thistype= 'restaurant'
      myresponse = HTTParty.get( "https://maps.googleapis.com/maps/api/place/search/json?location=#{latlng.join(',')}&types=#{thistype}&radius=#{thisradius}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")   
      @latlng=latlng
      @features = myresponse  
      @resultscount = @features['results'].count      
      @locations = Location.near(params[:search], 5, :order => :distance)
    else
      #if no address entered, use default address.  Helps with initial opening page
      ipresult = request.remote_ip
      #remember to replace hard coded ip address with ipresult in order to have dynamic location search.
      @result = HTTParty.get( "http://geoip3.maxmind.com/b?l=NTCuakb7nqa6&i=74.244.43.206")
      @splitResult = @result.split(',')
      #@result = HTTParty.get( "http://geoip3.maxmind.com/b?l=NTCuakb7nqa6&i=#{ipresult}")
      # @result = HTTParty.get( "http://api.hostip.info/get_html.php?ip=#{ipresult}&position=true")
         
      url = "https://maps.googleapis.com/maps/api/place/search/json?"
      @latlng= [@splitResult[3],@splitResult[4]]
      lnglat = [@splitResult[3],@splitResult[4]]
      #lnglat = '@latlng[0], @latlng[1]'
      thisradius= '15000'
      thistype= 'restaurant'
      myresponse = HTTParty.get( "https://maps.googleapis.com/maps/api/place/search/json?location=#{lnglat.join(',')}&radius=#{thisradius}&types=#{thistype}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")   
      @features = myresponse
      @resultscount = @features['results'].count  
      @locations = Location.all
      #@locations = Location.find(:all, :conditions => "latitude = #{@splitResult[3]}")
    end
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @locations }
    end
  end
 
  def details
    require 'rubygems'
    require 'twitter'
    reference = params[:reference]   
    @search = Rails.cache.read("searchtext")
    @details = HTTParty.get( "https://maps.googleapis.com/maps/api/place/details/json?reference=#{reference}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")
   
    unless Location.find_by_reference(reference).nil?
      @newtweets = Twitter.user_timeline(Location.find_by_reference(reference).twitter_name).first.text
      #@newtweets = Twitter.user_timeline(@details['result']['twitter']).first.text  
    end
  end
    
 
   
  def show
    @location = Location.find(params[:id])
    
    begin
      # convert real name to id
      res_page = RestClient.get "https://graph.facebook.com/#{@location.facebook_page_id}"
      result_page = ActiveSupport::JSON.decode(res_page) 
      
      facebook_link = "http://www.facebook.com/feeds/page.php?id=#{result_page["id"]}&format=json"
      res = RestClient.get facebook_link
      @feed = ActiveSupport::JSON.decode(res)
    rescue
    end
    
    begin
      twitter_link = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{@location.twitter_name}"
      timeline = RestClient.get twitter_link
      @tweet = ActiveSupport::JSON.decode(timeline)
    rescue
    end
    
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
  
  def get_place_report(location, long, lat)
    myarray = {:location => {:lat => lat.to_f, :lng => long.to_f},
      :accuracy => 50, :name => location[:name], 
      :types => [location[:types]], :language => "en-AU"}
    json_string = myarray.to_json()
    
    res = RestClient.post "https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc", json_string, :content_type => :json, :accept => :json
    ActiveSupport::JSON.decode(res)
  end
  
end 

