class Place
  
  attr_accessor :name, :vicinity, :reference, :geocode, :categories, :types,
                :phone_number, :website, :full_address

  RADIUS = 750
  MILES_PER_KILOMETER = 0.621371192
  API_KEY = "AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc"
  SEARCH_REQUEST_URL = "https://maps.googleapis.com/maps/api/place/search/json?location=%.8f,%.8f&types=%s&radius=%d&sensor=true&key=#{API_KEY}"
  DETAILS_REQUEST_URL = "https://maps.googleapis.com/maps/api/place/details/json?reference=%s&sensor=true&key=#{API_KEY}"

  def initialize(result)
    @name = result['name']
    @vicinity = result['vicinity']
    @reference = result['reference']
    @geocode = [ result['geometry']['location']['lat'].to_f,
                 result['geometry']['location']['lng'].to_f ]
    @types = result['types']
    @categories = LocationCategory.find_all_by_types(@types)
    if result['address_components'] # detail
      @phone_number = result['formatted_phone_number']
      @website = result['website']
      @full_address = result['formatted_address']
    end
  end

  def distance(other_geocode)
    FasterHaversine.distance(geocode.first, geocode.last, other_geocode.first, other_geocode.last) * MILES_PER_KILOMETER
  end

  def in_category?(category)
    categories.include? category
  end
  
  class << self

    def find_by_geocode(geocode, types = LocationCategory.all_types, radius = RADIUS)
      types = CGI.escape(types.join('|'))
      url = sprintf(SEARCH_REQUEST_URL, geocode.first, geocode.last, types, radius)
      results = HTTParty.get(url)['results']

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
    