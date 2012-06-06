# Loads events from the NearbyThis database
class EventSet
  include Enumerable
  attr_reader :events

  MIN_EVENTS = 2
  RADIUS     = 2 # miles
  WITHIN     = 2.weeks

  def initialize(events)
    @events = events.sort do |a,b| 
      case  # sort by start date (nils come first)
        when a.start_date.nil?; -1
        when b.start_date.nil?; 1
        else a.start_date <=> b.start_date
      end
    end
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
      events = Event.upcoming_in(WITHIN).near(coordinates, RADIUS)
      if events.count < MIN_EVENTS
        EventImporter.new(coordinates).delay.import
      end
      new(events)
    end

  end

end