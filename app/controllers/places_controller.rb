class PlacesController < ApplicationController

  has_mobile_fu

  before_filter :redirect_mobile_request, :except => :recent_tweeters
  respond_to :html, :json, :js
  
  RADIUS = '750'
  DEFAULT_COORDINATES = [33.7489954, -84.3879824] # Atlanta, GA

  # GET / (/places)
  def index
    set_coordinates

    category = params[:types].blank? ? LocationCategory::EatDrink : LocationCategory.find_by_name(params[:types])
    @locations = Location.find_by_geocode_and_category(@coordinates, category)
    @locations.reject! {|l| l.reference.nil? } # TODO: Remove this once reference can be gauranteed

    # Fire off a delayed job to update the twitter statuses
    Jobs::TwitterStatusUpdate.new(@locations).delay.process

    @places = Place.find_by_geocode(@coordinates, category.types)
    remove_duplicate_places unless @places.empty? || @locations.empty?
    @events = Event.upcoming_near(@coordinates)
    
    # merge location and places
    @locations = [@locations + @places].flatten.sort do |a,b|
      a.distance_from(@coordinates) <=> b.distance_from(@coordinates)
    end

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
    @location = Location.find_by_reference(reference) || Place.find_by_reference(reference)
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
  
  private
  
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
  
  def redirect_mobile_request
    redirect_to :controller => 'mobile', :action => 'index' if is_mobile_device?
  end
  
  def remove_duplicate_places
    @places.reject! do |place| 
      exclude_place? place
    end
  end

  def exclude_place?(place)
    @locations.any? do |location| 
      place.name == location.name ||
      (!place.address.blank? && place.address.include?(location.address)) ||
      place.coordinates == location.coordinates
    end
  end

end