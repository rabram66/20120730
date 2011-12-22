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
    @order = params[:order]

    @locations = @locations.all_by_filters(@general_type, @radius, @coordinates, @name, @order).page(params[:page])
    respond_with @locations
  end
  
  # GET /locations/1
  def show
    respond_with @location
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
    respond_with @location
  end

  # PUT /locations/1
  def update
    if @location.update_attributes(params[:location])
      flash[:notice] = "Successfully updated location."
    end
    respond_with @location
  end

  # DELETE /locations/1
  def destroy
    @location.destroy
    flash[:notice] = "Successfully destroyed location."
    respond_with @location
  end
  
end 

