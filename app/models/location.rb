class Location < ActiveRecord::Base
  
  include HTTParty
  base_uri 'https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc1'

def fulladdress
    [address, city, state]
  end
  attr_accessible :name, :address, :city, :state, :twitter, :phone, :latitude, :longitude, :reference
  geocoded_by :address
  after_validation :geocode
  
end