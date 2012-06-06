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

    @deals     = DealSet.near(@geocode)
    @events    = EventSet.upcoming_near(@geocode)
  end
  
  # GET the detail for a location/place
  def detail
    reference = params[:id]

    case reference
    when /^[A-Z]/ 
      @location = Place.find_by_reference(reference)
      if @location
        redirect_to url_for_location_details(@location), :status => 301 and return
      end
    when /^#{PlaceMapping::SLUG_PREFIX}/
      @location = Place.find_by_slug(reference)
    else
      @location = Location.find(reference)
    end

    not_found unless @location # 404

    @twitter_mentions = @location.twitter_mentions
    
    if Location === @location
      @twitter_status = @location.twitter_status
      @facebook_status = @location.facebook_status
    end
  end

  def deals
    @deals = DealSet.near(@geocode)
  end
  
  def events
    @events = EventSet.upcoming_near(@geocode)
  end

  def event
    @event = Event.find(params[:id])
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
      redirect_path = case request.fullpath
      when %r{mobile/detail/}
        request.fullpath.gsub(%r{mobile/detail/},'details/')
      else
        request.fullpath.gsub(%r{/mobile}, '')
      end
      redirect_to redirect_path
    end
  end

end
