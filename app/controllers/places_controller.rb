class PlacesController < ApplicationController

  has_mobile_fu

  before_filter :tablet_device_fallback
  before_filter :set_pjax, :redirect_mobile_request, :except => :favorite
  before_filter :set_coordinates, :except => [:search, :ical, :favorite]
  respond_to :html, :json, :js

  layout :set_layout

  RADIUS = '750'
  DEFAULT_COORDINATES = Rails.application.config.app.default_coordinates
  DEFAULT_SEARCH      = Rails.application.config.app.default_search
  
  def start
    redirect_to root_path
  end
  
  def about
    load_for_index unless pjax?
  end

  def advertise
    load_for_index unless pjax?
  end

  def index
    load_for_index unless pjax?
  end

  def press
    load_for_index unless pjax?
  end
  
  # GET /search?lat=33.3lng=-84.5 # Called via ajax based on browser geo nav
  def search
    @coordinates = [params[:lat].to_f, params[:lng].to_f]
    session[:search] = @coordinates
    redirect_to places_path
  end
  
  # GET /details/QUIOUREIOWFI-FJSDJFII38427387 (reference)
  def details
    load_for_index unless pjax?
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

  def event
    load_for_index
    load_event
  end

  def ical
    load_event
    render :text => to_ical(@event), :header => {'Content-Type'=>'text/calendar'}, :layout => false
  end

  # XHR POST 
  def favorite
    reference = params[:reference]
    if reference =~ /^#{PlaceMapping::SLUG_PREFIX}/
      Place.favorite(reference)
    else
      Location.favorite(reference)
    end
    render :nothing => true
  end
  
  private

  def tablet_device_fallback
    request.format = :html if is_tablet_device?
  end
  
  def pjax?
    @pjax
  end

  def set_pjax
    @pjax = !!request.headers['X-PJAX']
  end

  def set_layout
    pjax? ? false : 'places'
  end

  def load_for_index
    @location_type = params[:location_type] || 'EAT'

    unless fragment_exist?("search_#{@location_type}_#{@coordinates.join('_')}")
      category = case @location_type
        when /eat/i; LocationCategory::EatDrink
        when /shop/i; LocationCategory::ShopFind
        when /fun/i; LocationCategory::Play
        when /spa/i; LocationCategory::Spa
      end

      @locations = PlaceLoader.near(@coordinates, category)

      @events = EventSet.upcoming_near(@coordinates)
      @deals = DealSet.near( @coordinates )
    end

    # Not needed until UI for locations w/deals is determined
    # @locations.each do |location|
    #   location.deals = @deals.matching_deals(location)
    # end
  end
  
  def load_from_reference
    reference = params[:reference]
    @location = reference =~ /^[A-Z]/ ? Place.find_by_reference(reference) : Location.find(reference)
  end

  def load_event
    @event = Event.find(params[:id])
  end

  def to_ical(event)
    RiCal.Calendar do |cal|
      cal.event do |cal_event|
        cal_event.summary = event.name
        cal_event.dtstart = event.start_date if event.start_date
        cal_event.dtend = event.end_date if event.end_date
        cal_event.location = event.full_address
        cal_event.url = event_url(event.id)
      end
    end
  end
  
  def set_coordinates
    @search = params[:search]
    lat,lng = params[:lat], params[:lng] 

    @coordinates = case
      when !lat.blank? && !lng.blank?; [lat.to_f, lng.to_f]
      when !@search.blank?; Geocoder.coordinates(@search)
      when session[:search]
        searching_for = Geocoder.search(session[:search]).first
        @search = searching_for && searching_for.address 
        session[:search]
      when cookies[:address]
        cookie_bits = cookies[:address].split("&")
        @search = cookie_bits.last if cookie_bits.length > 2
        cookie_bits[0,2].map(&:to_f) 
    end
    
    unless @coordinates
      # Fallback to IP then Atlanta, GA
      @coordinates = Geocoder.coordinates(request.remote_ip)
      if !@coordinates || (@coordinates.first == 0.0 && @coordinates.last == 0.0)
        @coordinates = DEFAULT_COORDINATES
        @search = DEFAULT_SEARCH
      else
        @search = Geocoder.search(@coordinates).first.address
      end
    else
      # Only set when coordinates not from fallback (forces browser geonav)
      session[:search] = @coordinates
    end
    
    cookies[:address] = { :value => (@coordinates.clone << @search).join('&'), :expires => 1.year.from_now }
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