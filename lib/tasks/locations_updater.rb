class LocationsUpdater
  
  attr_reader :near

  def initialize(args)
    @near = args[:near]
  end
  
  # def run
  #   coords = Geocoder.coordinates(near)
  #   locations = Location.find_by_geocode coords
  #   locations.each do |l|
  #     tweet = l.twitter_status
  #     if tweet
  #       l.update_attributes(:profile_image_url => tweet.profile_image_url)
  #       puts "Setting profile image url of #{l.name}"
  #     end
  #   end
  # end

  def run
    Location.where('twitter_name IS NOT NULL AND description IS NULL').limit(60).each {|l| l.update_twitter_profile}
  end

end