# Things common to Location and Place
module LocationPlace

  MILES_PER_KILOMETER = 0.621371192

  def distance_from(point)
    FasterHaversine.distance(geo_code.first, geo_code.last, point.first, point.last) * LocationPlace::MILES_PER_KILOMETER
  end

end