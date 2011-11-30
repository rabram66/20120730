class Location < ActiveRecord::Base

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
  
  GEO_ATTRS = %w(city state address latitude longitude) # Geocode on change
  REF_ATTRS = GEO_ATTRS + %w(name types) # Update Places reference on change

  before_validation do
    geocode unless (GEO_ATTRS & changes.keys).empty?
    update_reference unless (REF_ATTRS & changes.keys).empty?
  end
  
  before_destroy :delete_reference

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
  
  def facebook_page_url
    "http://www.facebook.com/#{facebook_page_id}" if facebook_page_id
  end
  
  def geo_code
    [latitude, longitude]
  end
  
  private
  
  def update_reference
    delete_reference
    add_reference
  end

  def add_reference
    Place.add self
  end

  def delete_reference
    Place.delete(self) if attribute_present?(:reference)
  end
  
end