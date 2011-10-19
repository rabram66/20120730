class Event < ActiveRecord::Base
  validates :name,  :presence => true
  validates :address,  :presence => true
  validates :description,  :presence => true
  geocoded_by :address
  after_validation :geocode
end
