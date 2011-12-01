class Event < ActiveRecord::Base

  validates_presence_of :name, :address, :description

  geocoded_by :address

  scope :upcoming, where("(start_date ISNULL AND end_date ISNULL) OR (start_date >= :today OR end_date >= :today)", {:today => Date.today})  

  after_validation do 
    geocode if changes.keys.include?('address')
  end

  def geo_code
    [latitude, longitude]
  end

  class << self
    def find_by_geocode(coordinates)
      self.near(coordinates, 2, :order => :distance)
    end
    def upcoming_near(coordinates)
      upcoming.find_by_geocode(coordinates).order(:start_date)
    end
  end

end
