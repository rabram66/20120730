class Place

  include Address
  
  attr_accessor :name, :reference, :latitude, :longitude, :categories, :types,
                :phone_number, :website, :full_address, :rating, :city, :address, :state

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
      @reference = result['reference']
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

  def in_category?(category)
    categories.include? category
  end

  def matching_deal=(match)
    @matching_deal = match
  end
  
  def matching_deal?
    @matching_deal
  end
  
  def twitter_mentions(count=10)
    if name.blank?
      []
    else
      tweets = Tweet.search(name, count*2) # Fetch 2 times the count requested
      filtered = TweetFilter::Chain.new( TweetFilter::DuplicateText.new, TweetFilter::MentionCount.new(5) ).filter(tweets)
      filtered[0,count]
    end
  end

  class << self
    
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
      result = HTTParty.get(url)['result']
      Place.new(result)
    end

  end

end