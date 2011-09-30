class Location < ActiveRecord::Base
  
  include HTTParty
  base_uri 'https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc1'

  validates :name,  :presence => true
  validates :address,  :presence => true  
  validates :city,  :presence => true  
  validates :state,  :presence => true
  validates :phone,  :presence => true
  validates :email,  :presence => true
  validates :types,  :presence => true
  validates :twitter_name,  :presence => true
  validates :facebook_page_id,  :presence => true
  
  
  def fulladdress
    [address, city, state]
  end
  
  def full_address
    "#{address} #{city}, #{state}"
  end
  
  attr_accessible :name, :address, :city, :state, :twitter, 
                  :phone, :latitude, :longitude, :reference, :email, 
                  :types, :twitter_name, :facebook_page_id
  geocoded_by :address
  after_validation :geocode
  
end