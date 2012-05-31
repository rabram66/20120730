# Loads events from the NearbyThis database and Google Places
class PlaceLoader

  attr_reader :locations, :places, :coordinates, :category

  def initialize(coordinates, category=nil)
    @coordinates = coordinates
    @category = category
  end

  class << self
    def near(coordinates, category=nil)
      new(coordinates, category).load
    end
  end

  def load
    @locations = category ? Location.find_by_geocode_and_category(coordinates, category) : Location.find_by_geocode(coordinates)
    @places    = category ? Place.find_by_geocode(coordinates, category.types) : Place.find_by_geocode(coordinates)

    # Fire off a delayed job to update the twitter statuses
    Jobs::TwitterStatusUpdate.new(locations).delay.process

    remove_duplicates unless places.length == 0 || locations.length == 0

    associate_place_mappings

    # merge location and places
    [locations + places].flatten.sort do |a,b|
      a.distance_from(coordinates) <=> b.distance_from(coordinates)
    end
  end

  private

  def associate_place_mappings
    mappings = Hash[PlaceMapping.where(:places_id => places.map(&:places_id)).map{|p| [p.places_id, p]}]
    places.each do |place|
      place.mapping = mappings[place.places_id]
    end
  end
    
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