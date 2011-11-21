class Location < ActiveRecord::Base

  include LocationPlace
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
  
  belongs_to :user

  def full_address
    "#{address} #{city}, #{state}"
  end
  
  attr_accessible :name, :address, :city, :state, :twitter, 
                  :phone, :latitude, :longitude, :reference, :email, 
                  :types, :twitter_name, :facebook_page_id, :user_id
  geocoded_by :full_address
  after_validation :geocode

  def categories
    [LocationCategory.find_by_name(general_type)]
  end
  
  def twitter_status
    Tweet.latest(twitter_name) if twitter_name
  end

  def twitter_mentions
    twitter_name ? Tweet.search(twitter_name) : []
  end
  
  def facebook_status
    WallPost.latest(facebook_page_id) if facebook_page_id
  end

  class << self
    
    def find_by_geocode(geocode)
      self.near(geocode, 2, :order => :distance)
    end

  end
    
  
end