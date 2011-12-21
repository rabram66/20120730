class Event < ActiveRecord::Base

  include Address

  ADDRESS_ATTRS = %w(city state address)

  validates_presence_of :name, :address, :city, :state, :description
  attr_accessible :name, :address, :city, :state, :description, 
                  :latitude, :longitude, :user_id

  belongs_to :user
  geocoded_by :full_address

  scope :upcoming, where("(start_date ISNULL AND end_date ISNULL) OR (start_date >= :today OR end_date >= :today)", {:today => Date.today})  

  after_validation do 
    geocode if !(ADDRESS_ATTRS & changes.keys).empty? || latitude.blank? || longitude.blank?
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
