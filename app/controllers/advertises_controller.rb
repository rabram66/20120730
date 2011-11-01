class AdvertisesController < ApplicationController
  before_filter :role
  RADIUS = '5000' 
  # GET /advertises
  # GET /advertises.xml
  def index
    
    @advertises = Advertise.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @advertises }
    end
  end

  # GET /advertises/1
  # GET /advertises/1.xml
  def show
    @advertise = Advertise.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @advertise }
    end
  end

  # GET /advertises/new
  # GET /advertises/new.xml
  def new
    @advertise = Advertise.new
    @result = nil
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @advertise }
    end
  end

  # GET /advertises/1/edit
  def edit
    @advertise = Advertise.find(params[:id])
    
    address = @advertise.address_name
    coordinates= Geocoder.coordinates(address)            
    xml_res = Array.new
    begin
      near_your_locations = HTTParty.get("https://maps.googleapis.com/maps/api/place/search/json?location=#{coordinates.join(',')}&types=&radius=#{RADIUS}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")
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
    xml_res = xml_res.sort
    @results = xml_res  
  end

  # POST /advertises
  # POST /advertises.xml
  def create
    @advertise = Advertise.new(params[:advertise])
    @advertise.business_name = params[:advertise][:business_name].join(",") unless params[:advertise][:business_name].blank?
    respond_to do |format|
      if @advertise.save
        format.html { redirect_to(@advertise, :notice => 'Advertise was successfully created.') }
        format.xml  { render :xml => @advertise, :status => :created, :location => @advertise }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @advertise.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /advertises/1
  # PUT /advertises/1.xml
  def update
    @advertise = Advertise.find(params[:id])      
    respond_to do |format|
      if @advertise.update_attributes(params[:advertise])
        format.html { redirect_to(@advertise, :notice => 'Advertise was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @advertise.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /advertises/1
  # DELETE /advertises/1.xml
  def destroy
    @advertise = Advertise.find(params[:id])
    @advertise.destroy

    respond_to do |format|
      format.html { redirect_to(advertises_url) }
      format.xml  { head :ok }
    end
  end
end
