class Location < ActiveRecord::Base
  
  include Address

  validates_presence_of :name, :address, :city, :state, :types, :general_type
  
  belongs_to :user
  
  alias_attribute :phone_number, :phone

  attr_accessible :name, :address, :city, :state, :twitter, 
                  :phone, :latitude, :longitude, :reference, :email, 
                  :types, :twitter_name, :facebook_page_id, :user_id
                  
  # Rating as implemented in Location, here, returns nil (no-op) for Place compatability
  attr_accessor :rating # virtual; not persisted

  geocoded_by :full_address
  
  ADDRESS_ATTRS = %w(city state address)
  GEO_ATTRS = %w(latitude longitude) # Geocode on change
  REF_ATTRS = ADDRESS_ATTRS + GEO_ATTRS + %w(name types) # Update Places reference on change

  before_validation do
    self.general_type = LocationCategory.find_by_type(types).name
  end

  before_save do
    geocode if !(ADDRESS_ATTRS & changes.keys).empty? || latitude.blank? || longitude.blank?
    update_reference if !(REF_ATTRS & changes.keys).empty?
  end
  
  before_destroy :delete_reference

  class << self
    def find_by_geocode(coordinates, radius_in_miles=20, limit=50)
      self.near(coordinates, radius_in_miles, :order => :distance).limit(limit)
    end
    def find_by_geocode_and_category(coordinates,category=LocationCategory::EatDrink)
      find_by_geocode(coordinates).where(:general_type => category.name)
    end
    def all_by_filters(general_type=nil, radius=nil, coordinates=nil, name=nil, limit=100)
      radius ||= 20
      relation = scoped
      relation = relation.where(:general_type => general_type) if general_type
      relation = relation.where(arel_table[:name].matches("%#{name}%")) if name
      relation = relation.near(coordinates, radius) if coordinates
      relation = relation.limit(limit) if limit
      relation = relation.order(:name)
      relation
    end
      
  end

  def categories
    [LocationCategory.find_by_name(general_type)]
  end
  
  def twitter_status
    Tweet.user_status(twitter_name) unless twitter_name.blank?
  end
  
  def recent_tweet?(within=1.day)
    false
    # ((Time.now - twitter_status.created_at).abs < within) if twitter_status
  end
  
  def tweets(count=10)
    !twitter_name.blank? ? Tweet.latest(twitter_name,count) : []
  end

  def twitter_mentions(count=10)
    if twitter_name.blank?
      []
    else
      tweets = Tweet.mentions(twitter_name, count*2) # Fetch 2 times the count requested
      filtered = TweetFilter::Chain.new( TweetFilter::DuplicateText.new, TweetFilter::MentionCount.new(5) ).filter(tweets)
      filtered[0,count]
    end
  end

  def matching_deal=(match)
    @matching_deal = match
  end
  
  def matching_deal?
    @matching_deal
  end

  def facebook_status
    WallPost.latest(facebook_page_id) unless facebook_page_id.blank?
  end

  def facebook_posts(count=10)
    !facebook_page_id.blank? ? WallPost.feed(facebook_page_id,count) : []
  end
  
  def facebook_page_url
    "http://www.facebook.com/#{facebook_page_id}" unless facebook_page_id.blank?
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