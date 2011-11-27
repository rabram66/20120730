class Location < ActiveRecord::Base

  include HTTParty

  base_uri 'https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc1'

  validates :name,  :presence => true
  validates :address,  :presence => true  
  validates :city,  :presence => true  
  validates :state,  :presence => true
  validates :types,  :presence => true
  validates :reference, :presence => true
  
  belongs_to :user
  
  alias_attribute :phone_number, :phone

  def full_address
    "#{address} #{city}, #{state}"
  end
  
  attr_accessible :name, :address, :city, :state, :twitter, 
                  :phone, :latitude, :longitude, :reference, :email, 
                  :types, :twitter_name, :facebook_page_id, :user_id
                  
  # Rating as implemented in Location, here, returns nil (no-op) for Place compatability
  attr_accessor :rating # virtual; not persisted

  geocoded_by :full_address

  # Must be geo-coded before updating the reference
  before_validation :geocode, :update_reference

  class << self
    def find_by_geocode(coordinates)
      self.near(coordinates, 2, :order => :distance)
    end
  end

  def categories
    [LocationCategory.find_by_name(general_type)]
  end
  
  def twitter_status
    Tweet.latest(twitter_name) if twitter_name
  end
  
  def tweets(count=10)
    twitter_name ? Tweet.latest(twitter_name,count) : []
  end

  def twitter_mentions(count=10)
    twitter_name ? Tweet.search(twitter_name,count) : []
  end
  
  def facebook_status
    WallPost.latest(facebook_page_id) if facebook_page_id
  end

  def facebook_posts(count=10)
    facebook_page_id ? WallPost.feed(facebook_page_id,count) : []
  end
  
  def geo_code
    [latitude, longitude]
  end
  
  private
  
  def update_reference
    Place.delete self
    Place.add self
  end
    
  
end