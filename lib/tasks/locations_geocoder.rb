class LocationsGeocoder
  def run
    Location.where("latitude IS NULL AND city = 'Atlanta'").limit(200).each { |l| l.save }
  end
end