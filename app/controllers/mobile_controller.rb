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
    @places = Place.find_by_geocode(@geocode)
  end
  
  # GET the detail for a location/place
  def detail
    reference = params[:id]    
    place = Place.find_by_reference(reference)
    @location = Location.find_by_reference(reference)        

    if @location
      # @last_tweet = get_last_tweet(@location.twitter_name)    
      # @last_post = get_last_post(@location)      
      # @user_saying = get_tweet_search(@location.twitter_name)
    else
      @location = place
    end
  end
    
end
