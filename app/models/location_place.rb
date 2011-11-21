# Things common to Location and Place
module LocationPlace

  MILES_PER_KILOMETER = 0.621371192

  def distance(other_geo_code)
    FasterHaversine.distance(geo_code.first, geo_code.last, other_geo_code.first, other_geo_code.last) * LocationPlace::MILES_PER_KILOMETER
  end

end