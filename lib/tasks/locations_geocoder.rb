class LocationsGeocoder
  def run
    Location.where("latitude IS NULL AND state = 'NY'").limit(200).each { |l| l.save }
  end
end