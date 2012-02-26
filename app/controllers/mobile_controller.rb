class MobileController < ApplicationController

  has_mobile_fu

  layout 'mobile'
  before_filter :redirect_nonmobile_request
  before_filter :set_geocode, :except => [:index, :list]

  # GET The main page with a field to input the address, city, state or to use current location
  def index
  end

  def city
    @city = City.find(params[:city])
    redirect_to :action => :index unless @city
  end
  
  #GET the list of nearby locations using the search location
  def list
    @geocode = if params[:commit] == I18n.t('mobile.use_my_location_button') || params[:search].blank? || params[:search] == I18n.t('mobile.search_prompt')
      geocode_from_params
    else
      Geocoder.coordinates(params[:search]) || geocode_from_params
    end
    

    cookies[:geocode] = { :value => @geocode, :expires => 1.year.from_now }

    @locations = PlaceLoader.near(@geocode)

    @deals     = Deal.find_by_geocode(@geocode)
    @events    = EventSet.upcoming_near(@geocode)
  end
  
  # GET the detail for a location/place
  def detail
    reference = params[:id]
    @location = reference =~ /^[A-Z]/ ? Place.find_by_reference(reference) : Location.find(reference)
    
    @twitter_mentions = @location.twitter_mentions
    
    if Location === @location
      @twitter_status = @location.twitter_status
      @facebook_status = @location.facebook_status
    end
  end

  def deals
    @deals = Deal.find_by_geocode(@geocode)
  end
  
  def events
    @events = EventSet.upcoming_near(@geocode)
  end

  def event
    @event = (params[:id] =~ /^EB/) ? EventBrite.find_by_id(params[:id]) : Event.find(params[:id])
  end

  private
  
  def set_geocode
    @geocode = geocode_from_cookie || Rails.application.config.app.default_coordinates
  end
    
  def geocode_from_params
    [params[:lat].to_f, params[:lng].to_f]
  end

  def geocode_from_cookie
    cookies[:geocode] && cookies[:geocode].split('&').map{|v| v.to_f}
  end

  def redirect_nonmobile_request
    unless is_mobile_device?
      redirect_to request.fullpath.gsub(%r{mobile/detail/},'details/') if request.fullpath =~ %r{mobile/detail/}
    end
  end

end
