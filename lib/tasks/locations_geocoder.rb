class LocationsGeocoder
  def run
    Location.where('latitude IS NULL OR longitude IS NULL').limit(2500).each { |l| l.save }
  end
end