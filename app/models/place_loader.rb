# Loads events from the NearbyThis database and Google Places
class PlaceLoader

  attr_reader :locations, :places, :coordinates

  def initialize(coordinates)
    @coordinates = coordinates
  end

  class << self
    def near(coordinates)
      new(coordinates).load
    end
  end

  def load
    @locations = Location.find_by_geocode(coordinates)
    @places    = Place.find_by_geocode(coordinates)

    # Fire off a delayed job to update the twitter statuses
    Jobs::TwitterStatusUpdate.new(locations).delay.process

    remove_duplicates unless places.length == 0 || locations.length == 0

    # merge location and places
    [locations + places].flatten.sort do |a,b|
      a.distance_from(coordinates) <=> b.distance_from(coordinates)
    end
  end

  private
    
  def remove_duplicates
    if places
      places.each_with_index do |place, ndx|
        places[ndx] = nil if exclude_place?(place)
      end
      places.compact!
    end
  end

  def exclude_place?(place)
    # Exclude the place if there is a location with the same name, address, or lat-lng
    locations.any? do |location|
      ( place.name == location.name ) ||
      ( !place.address.blank? && place.address.include?(location.address) ) ||
      ( place.coordinates == location.coordinates )
    end
  end

end