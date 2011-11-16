class Place
  
  attr_accessor :name, :vicinity, :reference, :geocode

  RADIUS = 750
  API_KEY = "AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc"
  BASE_API_URL = "https://maps.googleapis.com/maps/api/place/search/json"
  MILES_PER_KILOMETER = 0.621371192

  def initialize(result)
    @name = result['name']
    @vicinity = result['vicinity']
    @reference = result['reference']
    @geocode = [ result['geometry']['location']['lat'].to_f,
                 result['geometry']['location']['lng'].to_f ] 
  end

  def distance(other_geocode)
    FasterHaversine.distance(geocode.first, geocode.last, other_geocode.first, other_geocode.last) * MILES_PER_KILOMETER
  end
  
  class << self

    def find_by_geocode(geocode, category = LocationCategory::EatDrink)
      types = category.types.join('%7C') # join with |
      url = "#{BASE_API_URL}?location=#{geocode.first},#{geocode.last}"
      url = "#{url}&types=#{types}"
      url = "#{url}&radius=#{RADIUS}&sensor=true&key=#{API_KEY}"
      results = HTTParty.get(url)
      results['results'].map {|result| Place.new(result)}
    end

  end

end
    