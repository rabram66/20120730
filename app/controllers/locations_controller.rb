class LocationsController < ApplicationController
       respond_to :html, :xml, :json, :js
        # GET /locations
  # GET /locations.xml

 def index
   
  if params[:search]
      #create session object containg search adddress
      @result = request.remote_ip
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
          url = "https://maps.googleapis.com/maps/api/place/search/json?"
          @latlng=['33.758922','-84.3871099']
          lnglat = '33.758922,-84.3871099'
          thisradius= '1500'
          thistype= 'restaurant'
           myresponse = HTTParty.get( "https://maps.googleapis.com/maps/api/place/search/json?location=#{lnglat}&radius=#{thisradius}&types=#{thistype}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")   
           @features = myresponse
           @resultscount = @features['results'].count  
          @locations = Location.find(:all, :conditions => "latitude = #{@latlng[0]}")
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
   @newtweets = Twitter.user_timeline(Location.find_by_reference(reference).twitter).first.text
    #@newtweets = Twitter.user_timeline(@details['result']['twitter']).first.text  
      end
    end
    
 
   
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
      
    respond_to do |format|
      if @location.save
 
        format.html { redirect_to(@location, :notice => 'Location was successfully created.') }
        format.xml  { render :xml => @location, :status => :created, :location => @location }
        
       #  @myGeo = HTTParty.post("https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc", :query => {[:location][])


       
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
 end 

