module Address

  MILES_PER_KILOMETER = 0.621371192

  def distance_from(point)
    FasterHaversine.distance(coordinates.first, coordinates.last, point.first, point.last) * Address::MILES_PER_KILOMETER
  end

  def coordinates
    [latitude, longitude]
  end
  
  def full_address
    [address, city, state].reject{|n| n.blank?}.join(', ')
  end

  def full_address=(value)
    parse_full_address(value)
  end

  def vicinity
    [address, city].reject{|n| n.blank?}.join(', ')
  end

  def page_title
    title = "#{name}"
    title << " - #{city}" unless city.blank?
    title << ", #{state}" unless state.blank?
    title
  end

  private
  
  def parse_full_address(value)
    parts = value.split(',')
    parts.map!{|p| p.strip }

    self.state = parts.pop
    self.city = parts.pop
    self.address = parts.join(', ')
  end

end