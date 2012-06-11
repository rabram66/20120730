class LocationsGeocoder
  def run
    Location.where("latitude IS NULL AND city = 'Atlanta'").limit(100).each { |l| l.save }
  end
end