require 'json'
require 'open-uri'

class LocationsController < ApplicationController
  before_filter :role, :except => [:load_deals, :details, :index, :delete_place, :load_business]
  before_filter :redirect_mobile_request
  
  respond_to :html, :xml, :json, :js
  
  RADIUS = '750'  
  DEFAULT_LOCATION = [33.7489954, -84.3879824] # Atlanta, GA

  before_filter :authenticate_user!, :only => [:new, :edit, :create, :update]
  

  # GET / (/locations/index)
  def index

    # TODO: Clean up
    @search = params[:search] unless params[:search].blank?
    unless @search.blank?
      @latlng = Geocoder.coordinates(@search)
      session[:search] = @latlng unless @latlng.blank?
    else      
      if session[:search].blank?
        ip_coords = Geocoder.coordinates(request.remote_ip)
        @latlng = ip_coords unless ip_coords.first == 0.0 && ip_coords.last == 0.0
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
    @locations = Location.find_by_geocode_and_category(coordinates, category)
    @locations.reject! {|l| l.reference.nil? } # TODO: Remove this once reference can be gauranteed

    @places = Place.find_by_geocode(coordinates, category.types)
    remove_duplicate_places unless @places.empty? || @locations.empty?
    @events = Event.upcoming_near(coordinates)
    
    # merge location and places
    @locations = [@locations + @places].flatten.sort do |a,b|
      a.distance_from(coordinates) <=> b.distance_from(coordinates)
    end
      
  end
  
  # TODO
  def search
    @latlng = [params[:latitude].to_f, params[:longitude].to_f]
    session[:search] = @latlng
    redirect_to locations_path
  end
  
  # GET /details/QUIOUREIOWFI-FJSDJFII38427387 (reference)
  def details
    reference = params[:reference]
    @location = Location.find_by_reference(reference) || Place.find_by_reference(reference)
    @origin_address = params[:address]
    
    if Location === @location
      @last_tweet = @location.twitter_status    
      @last_post = @location.facebook_status      
      @user_saying = @location.twitter_mentions(20)
    end
  end
  
  # XHR GET /delete_place/FKDASJFKJIWRIRU-4RJ3IWRJWI (Places reference)
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
  
  # XHR GET /load_deals
  def load_deals
    @deals = Deal.find_by_geocode( geocode_from_cookie )
    render :partial => 'deals', :layout => false
  end
   
  # GET /locations/1
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
  
  # XHR /load_page
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
      place.coordinates == location.coordinates
    end
  end

end 

