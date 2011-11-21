# Things common to Location and Place
module LocationPlace

  MILES_PER_KILOMETER = 0.621371192

  def distance(other_geocode)
    FasterHaversine.distance(geocode.first, geocode.last, other_geocode.first, other_geocode.last) * LocationPlace::MILES_PER_KILOMETER
  end

end