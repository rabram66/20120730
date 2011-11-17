class Place
  
  attr_accessor :name, :vicinity, :reference, :geocode, :categories, :types, :phone_number, :website

  RADIUS = 750
  API_KEY = "AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc"
  SEARCH_REQUEST_BASE_URL = "https://maps.googleapis.com/maps/api/place/search/json"
  MILES_PER_KILOMETER = 0.621371192
  DETAILS_REQUEST_BASE_URL = "https://maps.googleapis.com/maps/api/place/details/json"

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
    end
  end

  def distance(other_geocode)
    FasterHaversine.distance(geocode.first, geocode.last, other_geocode.first, other_geocode.last) * MILES_PER_KILOMETER
  end

  def in_category?(category)
    categories.include? category
  end
  
  class << self

    def find_by_geocode(geocode, types = LocationCategory.all_types)
      types = types.join('%7C') # join with |
      url = "#{SEARCH_REQUEST_BASE_URL}?location=#{geocode.first},#{geocode.last}"
      url = "#{url}&types=#{types}"
      url = "#{url}&radius=#{RADIUS}&sensor=true&key=#{API_KEY}"
      results = HTTParty.get(url)['results']

      # Remove empty names and duplicates
      results.reject! { |result| result['name'].blank? }
      results = Hash[ results.map { |result| [result['name'], result] } ].values
      
      places = results.map { |result| Place.new(result) }
    end

    def find_by_reference(reference)
      url = "#{DETAILS_REQUEST_BASE_URL}?reference=#{reference}&sensor=true&key=#{API_KEY}"
      result = HTTParty.get(url)['result']
      Place.new(result)
    end

  end

end
    