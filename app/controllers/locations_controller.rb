class LocationsController < ApplicationController
  respond_to :html, :xml, :json, :js
  load_and_authorize_resource

  # GET /locations
  def index
    @general_type = params[:general_type] unless params[:general_type].blank?
    @radius = params[:radius].to_i unless params[:radius].blank?
    @address = params[:address]

    @coordinates = Geocoder.coordinates(@address) unless @address.blank?
    @name = params[:name] unless params[:name].blank?
    @order = params[:order] || 'name'
    @to_verify = params[:to_verify] == 'true'
    @to_geocode = params[:to_geocode] == 'true'
    @active = case params[:active]
      when 'Active'; true
      when 'Inactive'; false
      else
        nil
    end 

    @locations = @locations.all_by_filters(
      :general_type => @general_type,
      :radius       => @radius,
      :coordinates  => @coordinates, 
      :name         => @name, 
      :order        => @order, 
      :to_verify    => @to_verify,
      :active       => @active,
      :to_geocode   => @to_geocode
    ).page(params[:page])
    respond_with @locations
  end
  
  # GET /locations/1
  def show
    show_location
  end

  # GET /locations/new
  def new
    respond_with @location
  end
  
  # GET /locations/1/edit
  def edit
    respond_with @location
  end

  # POST /locations
  def create
    if @location.save
      flash[:notice] = "Successfully created location."  
    end
    show_location
  end

  # PUT /locations/1
  def update
    if @location.update_attributes(params[:location])
      flash[:notice] = "Successfully updated location."
    end
    redirect_to :action => :index
  end

  # DELETE /locations/1
  def destroy
    @location.destroy
    flash[:notice] = "Successfully destroyed location."
    redirect_to :action => :index
  end

  private
  
  def show_location
    respond_with(@location) do |format|
      format.html { redirect_to location_details_url(:reference => @location.reference) }
    end
  end
  
end 

