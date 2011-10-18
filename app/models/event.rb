class Event < ActiveRecord::Base
  validates :name,  :presence => true
  validates :address,  :presence => true
  validates :description,  :presence => true
end
