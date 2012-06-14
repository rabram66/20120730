class LocationsGeocoder
  def run
    Location.where("latitude IS NULL AND state = 'GA'").limit(200).each { |l| l.save }
  end
end