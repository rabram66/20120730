module Address

  MILES_PER_KILOMETER = 0.621371192

  def distance_from(point)
    FasterHaversine.distance(coordinates.first, coordinates.last, point.first, point.last) * Address::MILES_PER_KILOMETER
  end

  def coordinates
    [latitude, longitude]
  end
  
  def full_address
    "#{address}, #{city}, #{state}"
  end

  def vicinity
    [address, city].reject{|n| n.blank?}.join(', ')
  end

end