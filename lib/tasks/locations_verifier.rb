class LocationsVerifier
  
  attr_reader :older_than
  
  def initialize(older_than=60.days.ago)
  end

  def run
    locations = Location.to_verify(older_than)
    puts "Verifying locations with Google Places ... "
    unverified = []
    locations.each do |location|
      begin
        place = Place.find_by_reference location.reference
        location.verified!
        print 'v'
      rescue Places::Api::NotFound
        location.unverified!
        unverified << location.id
        print 'U'
      end
      unless location.save
        puts "\nUnable to save #{location.id}"
      end
      STDOUT.flush
    end
    puts "The following locations require verification: #{unverified.join(', ')}"
    puts "Done."
  end

end