include Geokit::Geocoders
require 'json'
require 'open-uri'

class MobileController < ApplicationController
  layout 'mobile', :except => :map #LAYOUT

  # GET The main page with a field to input the address, city, state or to use current location
  def index
  end
  
  #GET the list of nearby locations using the search location
  def list
    @geocode = if params[:commit] == I18n.t('mobile.use_my_location_button') || params[:search].blank? || params[:search] == I18n.t('mobile.search_prompt')
      [params[:lat].to_f, params[:lng].to_f]        
    else
      Geocoder.coordinates(params[:search])
    end

    @locations = Location.find_by_geocode(@geocode)
    @places = Place.find_by_geocode(@geocode)
    
    remove_duplicate_places unless @places.empty? || @locations.empty?
  end
  
  # GET the detail for a location/place
  def detail
    reference = params[:id]    
    @location = Location.find_by_reference(reference) || Place.find_by_reference(reference)
    
    if Location === @location
      @twitter_status = @location.twitter_status
      @facebook_status = @location.facebook_status
      @twitter_mentions = @location.twitter_mentions
    end
  end

  private

  def remove_duplicate_places
    if @places
      @places.each_with_index do |place, ndx|
        @places[ndx] = nil if exclude_place?(place)
      end
      @places.compact!
    end
  end
  
  def exclude_place?(place)
    # Exclude the place if there is a location with the same name, address, or lat-lng
    @locations.any? do |location|
      ( place.name == location.name ) ||
      ( place.vicinity && place.vicinity.include?(location.address) ) ||
      ( place.geo_code == location.geo_code )
    end
  end
  
  
    
end
