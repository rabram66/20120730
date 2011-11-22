class Event < ActiveRecord::Base

  validates :name,  :presence => true
  validates :address,  :presence => true
  validates :description,  :presence => true
  geocoded_by :address
  after_validation :geocode

  def geo_code
    [latitude, longitude]
  end

  class << self
    def find_by_geocode(coordinates)
      self.near(coordinates, 2, :order => :distance)
    end
  end

end
