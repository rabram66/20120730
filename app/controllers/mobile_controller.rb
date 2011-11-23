include Geokit::Geocoders
require 'json'
require 'open-uri'

class MobileController < ApplicationController
  layout 'mobile'

  before_filter :set_geocode, :except => [:index, :list]

  # GET The main page with a field to input the address, city, state or to use current location
  def index
  end
  
  #GET the list of nearby locations using the search location
  def list
    @geocode = if params[:commit] == I18n.t('mobile.use_my_location_button') || params[:search].blank? || params[:search] == I18n.t('mobile.search_prompt')
      geocode_from_params
    else
      Geocoder.coordinates(params[:search])
    end

    cookies[:geocode] = { :value => @geocode, :expires => 1.year.from_now }

    @locations = Location.find_by_geocode(@geocode)
    @places    = Place.find_by_geocode(@geocode)
    @deals     = Deal.find_by_geocode(@geocode)
    @events    = Event.find_by_geocode(@geocode)
    
    remove_duplicate_places unless @places.length == 0 || @locations.length == 0
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
    puts "Orig Geocode: #{@geocode.inspect}"
    puts "Dest Geocode: #{@location.geo_code.inspect}"
  end

  def deals
    @deals = Deal.find_by_geocode(@geocode)
  end
  
  def events
    @events = Event.find_by_geocode(@geocode)
  end

  def event
    @event = Event.find params[:id]
  end

  private
  
  def set_geocode
    @geocode = geocode_from_cookie || default_geocode
  end
    
  def geocode_from_params
    [params[:lat].to_f, params[:lng].to_f]
  end

  def geocode_from_cookie
    cookies[:geocode] && cookies[:geocode].split('&').map{|v| v.to_f}
  end

  def default_geocode
    [33.7489954, -84.3879824] # Atlanta, Georgia (center of our universe)
  end

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
