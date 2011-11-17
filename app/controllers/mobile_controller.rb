include Geokit::Geocoders
require 'json'
require 'open-uri'

class MobileController < ApplicationController
  layout 'mobile' #LAYOUT

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
  
  # GET the detail for a location
  def detail
  end
    

  private
end
