class Location < ActiveRecord::Base
  
  include Address
  include DealHolder

  validates_presence_of :name, :address, :city, :state, :types, :general_type
  validates_uniqueness_of :name, :scope => :address
  
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
    self.general_type = LocationCategory.find_by_type(types).name unless types.blank?
  end

  before_save do
    self.phone = phone.gsub(/[^0-9]/,'') unless phone.blank?
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
    def all_by_filters(general_type=nil, radius=nil, coordinates=nil, name=nil, order='name')
      relation = scoped
      relation = relation.where(:general_type => general_type) if general_type
      relation = relation.where(arel_table[:name].matches(name)) if name
      if coordinates
        order = "#{order},distance" unless order == 'distance'
        radius ||= 20
        relation = relation.near(coordinates, radius, :order => order)
      else
        relation = relation.order(order) if order != 'distance'
      end
      relation
    end
  end

  def categories
    [LocationCategory.find_by_name(general_type)]
  end

  # True if there any tweets (status or otherwise) for this location
  def tweets?
    twitter?
  end

  # True if this location has a twitter account
  def twitter?
    !twitter_name.blank?
  end
  
  def twitter_status
    Tweet.user_status(twitter_name) unless twitter_name.blank?
  end

  def twitter_deal?
    cached_twitter_status.deal? if cached_twitter_status
  end

  def twitter_page_url
    "http://twitter.com/#{twitter_name}" unless twitter_name.blank?
  end
  
  def recent_tweet?(within=1.day)
    # True if a cached twitter status or mention was made within last day
    recent_twitter_status?(within) || recent_twitter_mention?(within)
  end
  
  def recent_twitter_status?(within=1.day)
    ((Time.now - cached_twitter_status.created_at).abs < within) if cached_twitter_status
  end

  def recent_twitter_mention?(within=1.day)
    unless cached_twitter_mentions.empty?
      cached_twitter_mentions.any? { |tweet| 
        (Time.now - tweet.created_at).abs < within 
      }
    end
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

  def facebook?
    !facebook_page_id.blank?
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

  def cached_twitter_status
    twitter? ? Tweet.cached_user_status(twitter_name) : nil
  end

  def cached_twitter_mentions
    twitter? ? (Tweet.cached_mentions(twitter_name) || []) : []
  end
  
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