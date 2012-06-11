class LocationsGeocoder
  def run
    Location.where("latitude IS NULL AND city = 'New York'").limit(200).each { |l| l.save }
  end
end