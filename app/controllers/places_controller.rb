class PlacesController < ApplicationController

  has_mobile_fu

  before_filter :redirect_mobile_request, :except => :recent_tweeters
  before_filter :redirect_to_start, :only => :index

  respond_to :html, :json, :js
  
  RADIUS = '750'
  DEFAULT_COORDINATES = Rails.application.config.app.default_coordinates
  
  def start
  end

  # GET / (/places)
  def index
    set_coordinates

    category = params[:types].blank? ? LocationCategory::EatDrink : LocationCategory.find_by_name(params[:types])

    @locations = PlaceLoader.near(@coordinates, category)

    @events = EventSet.upcoming_near(@coordinates)
    @deals = Deal.find_by_geocode( @coordinates )

    @locations.each do |location|
      location.deals = @deals.matching_deals(location)
    end
  end
  
  # GET /search?lat=33.3lng=-84.5 # Called via ajax based on browser geo nav
  def search
    @coordinates = [params[:lat].to_f, params[:lng].to_f]
    session[:search] = @coordinates
    redirect_to places_path
  end
  
  # GET /details/QUIOUREIOWFI-FJSDJFII38427387 (reference)
  def details
    reference = params[:reference]

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
    
    @origin_address = params[:address]
    @user_saying = @location.twitter_mentions(20)

    if Location === @location
      @last_tweet = @location.twitter_status    
      @last_post = @location.facebook_status      
    end
  end

  # XHR POST returns those twitter names with cached statuses
  def recent_tweeters
    within = 1.day
    now = Time.now
    twitter_names = params['n'] || []
    recently_updated = twitter_names.select { |name|
      status = Tweet.cached_user_status(name)
      ((now - status.created_at).abs < within) if status
    }
    render :json => recently_updated
  end

  # XHR POST 
  def favorite
    reference = params[:reference]
    if reference =~ /^[A-Z]/
      Place.favorite(reference)
    else
      Location.favorite(reference)
    end
    render :nothing => true
  end
  
  private
  
  def load_from_reference
    reference = params[:reference]
    @location = reference =~ /^[A-Z]/ ? Place.find_by_reference(reference) : Location.find(reference)
  end
  
  def set_coordinates
    @search = params[:search]
    lat,lng = params[:lat], params[:lng] 

    @coordinates = case
      when !lat.blank? && !lng.blank?; [lat.to_f, lng.to_f]
      when !@search.blank?; Geocoder.coordinates(@search)
      when session[:search]; session[:search]
      when cookies[:address]; cookies[:address].split("&").map(&:to_f) 
    end
    
    unless @coordinates
      # Fallback to IP then Atlanta, GA
      @coordinates = Geocoder.coordinates(request.remote_ip)
      if !@coordinates || (@coordinates.first == 0.0 && @coordinates.last == 0.0)
        @coordinates = DEFAULT_COORDINATES
      end
    else
      # Only set when coordinates not from fallback (forces browser geonav)
      session[:search] = @coordinates
    end
    
    cookies[:address] = { :value => @coordinates, :expires => 1.year.from_now }
  end

  def geocode_from_cookie
    cookies[:address] ? cookies[:address].split("&") : DEFAULT_COORDINATES
  end

  def redirect_to_start
    redirect_to :action => 'start' unless cookies[:address] || params[:search]
  end
  
  def redirect_mobile_request
    if is_mobile_device?
      if request.fullpath =~ %r{details/}
        redirect_to request.fullpath.gsub(%r{details/},'mobile/detail/')
      else
        redirect_to :controller => 'mobile', :action => 'index'
      end
    end
  end
  
end