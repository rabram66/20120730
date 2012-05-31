class Place

  include Address
  include DealHolder
  
  attr_accessor :name, :reference, :latitude, :longitude, :categories, :types,
                :phone_number, :website, :full_address, :rating, :city, :address, :state,
                :profile_image_url, :description, :places_id

  RADIUS = 750
  API_KEY = "AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc"
  SEARCH_REQUEST_URL  = "https://maps.googleapis.com/maps/api/place/search/json?location=%.8f,%.8f&types=%s&radius=%d&sensor=true&key=#{API_KEY}"
  DETAILS_REQUEST_URL = "https://maps.googleapis.com/maps/api/place/details/json?reference=%s&sensor=true&key=#{API_KEY}"
  ADD_PLACE_URL       = "https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=#{API_KEY}"
  DELETE_PLACE_URL    = "https://maps.googleapis.com/maps/api/place/delete/json?sensor=false&key=#{API_KEY}"

  def initialize(result=nil)
    if result
      @name = result['name']
      @rating = result['rating']
      unless result['vicinity'].blank?
        @city = result['vicinity'].split(',').last
        @address = result['vicinity'].split(',')[0..-2].join(',')
      end
      @profile_image_url = result['icon']
      @reference = result['reference']
      @places_id = result['id']
      @latitude = result['geometry']['location']['lat'].to_f
      @longitude = result['geometry']['location']['lng'].to_f
      @types = result['types']
      @categories = LocationCategory.find_all_by_types(@types)
      if result['address_components'] # detail
        @phone_number = result['formatted_phone_number']
        @website = result['website']
        @full_address = result['formatted_address']
      end
    end
  end

  # TODO implement
  def category_image_url
  end

  def tweets?
    !cached_tweets.empty?
  end

  # Location compatability methods 
  # TODO: Move these to a base module

  def twitter?
    false
  end
  
  def twitter_deal?
    false
  end

  def twitter_name
    nil
  end

  def facebook?
    false
  end

  def mapping
    unless @mapping
      @mapping = PlaceMapping.find_by_places_id(places_id) || PlaceMapping.create!(:name => name, :city => city, :places_id => places_id, :reference => reference)
    end
    @mapping
  end

  def mapping=(mapping)
    @mapping = mapping
  end

  # End compatability methods

  def in_category?(category)
    categories.include? category
  end

  def twitter_mentions(count=10)
    if name.blank?
      []
    else
      tweets = cached_tweets
      if tweets.empty?
        tweets = Tweet.geosearch("\"#{name}\"", coordinates, 5, count*2) # Fetch 2 times the count requested
        filtered = TweetFilter::Chain.new( TweetFilter::DuplicateText.new, TweetFilter::MentionCount.new(5) ).filter(tweets)
        filtered[0,count]
        self.cached_tweets = tweets
      end
      tweets || []
    end
  end
  
  def recent_tweet?(within=1.day)
    !!(unless cached_tweets.empty?
      cached_tweets.any? { |tweet| 
        (Time.now - tweet.created_at).abs < within 
      }
    end)
  end

  def recent_tweets(within)
    cached_tweets.select { |tweet|
      (Time.now - tweet.created_at).abs < within
    }
  end

  def tweet_count(within=7.days)
    recent_tweets(within).length
  end
  
  def favorites_count
    mapping.favorites_count
  end

  def last_favorited_at
    mapping.last_favorited_at
  end
  
  def slug
    mapping.slug
  end

  class << self

    # No-op for the time being
    def favorite(slug)
      mapping = find(slug)
      mapping.update_attributes(:favorites_count => mapping.favorites_count + 1, :last_favorited_at => Time.now) if mapping
    end
    
    # Adds a Location to Google Places, and sets the generated reference on the location
    def add(location)
      body = {
        :location => {:lat => location.coordinates.first.to_f, :lng => location.coordinates.last.to_f},
        :accuracy => 50, #meters,
        :name     => location.name,
        :types    => [location.types],
        :language => 'en-US'
      }.to_json
      response = RestClient.post ADD_PLACE_URL, body, :content_type => :json, :accept => :json
      result = ActiveSupport::JSON.decode response
      if result['status'] == 'OK'
        location.reference = result['reference']
        true
      else
        Rails.logger.error "Unable to add Place for location #{location.name}: #{result}"
        false
      end
    end
    
    def delete(location)
      if location.reference
        body = {:reference => location.reference}.to_json
        response = RestClient.post DELETE_PLACE_URL, body, :content_type => :json, :accept => :json
        result = ActiveSupport::JSON.decode response
        if result['status'] == 'OK'
          location.reference = nil
          true
        else
          Rails.logger.error "Unable to delete Place for '#{location.name}' (#{location.reference}): #{result}"
          false
        end
      end
    end

    def find_by_geocode(coordinates, types = LocationCategory.all_types, radius = RADIUS)
      types = CGI.escape(types.join('|'))
      url = format(SEARCH_REQUEST_URL, coordinates.first, coordinates.last, types, radius)
      results = ActiveSupport::JSON.decode( RestClient.get(url) )['results']

      # Remove empty names and duplicates
      results.reject! { |result| result['name'].blank? }
      results = Hash[ results.map { |result| [result['name'], result] } ].values
      
      places = results.map { |result| Place.new(result) }
    end

    def find_by_reference(reference)
      url = sprintf(DETAILS_REQUEST_URL, reference)
      result = ActiveSupport::JSON.decode( RestClient.get(url) )['result']
      if result.nil?
        raise Places::Api::NotFound.new(reference)
      else
        Place.new(result)
      end
    end
    
    def find_by_slug(slug)
      if (mapping = PlaceMapping.find_by_slug(slug))
        place = Place.find_by_reference(mapping.reference)
        place.mapping = mapping
        place
      end
    end

    def favorite(id)
      place_mapping = PlaceMapping.find(id)
      place_mapping.update_attributes(:favorites_count => place_mapping.favorites_count + 1, :last_favorited_at => Time.now) if place_mapping
    end

  end
  
  private
  
  def twitter_search_cache_key
    "twitter:search:#{name}"
  end
  
  def cached_tweets
    Rails.cache.read(twitter_search_cache_key) || []
  end

  def cached_tweets=(tweets)
    Rails.cache.write(twitter_search_cache_key, tweets, :expires_in => 15.minutes) if tweets && !tweets.empty?
  end

end