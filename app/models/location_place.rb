# Things common to Location and Place
module LocationPlace

  MILES_PER_KILOMETER = 0.621371192

  def distance_from(point)
    FasterHaversine.distance(coordinates.first, coordinates.last, point.first, point.last) * LocationPlace::MILES_PER_KILOMETER
  end

  def coordinates
    [latitude, longitude]
  end

end