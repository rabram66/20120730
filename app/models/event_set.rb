# Loads events from the NearbyThis database and EventBrite
class EventSet
  include Enumerable
  attr_reader :events

  def initialize(events)
    @events = events.sort_by(&:start_date)
  end
  
  def each
    for event in events
      yield event
    end
  end

  def happening_now
    events.select{|event| event.happening_now?}.sort_by(&:rank)
  end

  def coming_soon
    events.select{|event| event.coming_soon?}.sort_by(&:rank)
  end

  class << self
    def upcoming_near(coordinates)
      EventSet.new(Event.upcoming_near(coordinates) + EventBrite.geosearch(coordinates))
    end
  end

end