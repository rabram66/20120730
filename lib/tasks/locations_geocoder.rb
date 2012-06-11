class LocationsGeocoder
  def run
    Location.where('latitude IS NULL OR longitude IS NULL').limit(200).each { |l| l.save }
  end
end