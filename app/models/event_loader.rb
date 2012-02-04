# Loads events from the NearbyThis database and EventBrite
class EventLoader
  
  class << self
    
    def upcoming_near(coordinates)
      Event.upcoming_near(coordinates) + EventBrite.geosearch(coordinates)
    end
    
  end

end