class Location < ActiveRecord::Base

  extend FriendlyId
  
  include Address
  include DealHolder

  validates_presence_of :name, :address, :city, :state, :types, :general_type
  validates_uniqueness_of :name, :scope => :address
  
  belongs_to :user
  
  alias_attribute :phone_number, :phone

  attr_accessible :name, :address, :city, :state, :twitter, 
                  :phone, :latitude, :longitude, :reference, :email, 
                  :types, :twitter_name, :facebook_page_id, :user_id,
                  :verified, :verified_on, :verified_by, :favorites_count, :last_favorited_at,
                  :profile_image_url, :description, :active
                  
  # Rating as implemented in Location, here, returns nil (no-op) for Place compatability
  attr_accessor :rating # virtual; not persisted
  
  default_scope where(:active => true)
  
  friendly_id :slugged_id, :use => :history

  geocoded_by :full_address
  
  ADDRESS_ATTRS = %w(city state address)
  GEO_ATTRS = %w(latitude longitude) # Geocode on change
  REF_ATTRS = ADDRESS_ATTRS + GEO_ATTRS + %w(name types) # Update Places reference on change

  before_validation do
    self.general_type = LocationCategory.find_by_type(types).name unless types.blank?
  end

  before_save do
    self.phone = phone.gsub(/[^0-9]/,'') unless phone.blank?
    unless verified?
      self.verified_on = nil
      self.verified_by = nil
    end
    geocode if !(ADDRESS_ATTRS & changes.keys).empty? || latitude.blank? || longitude.blank?
    update_reference if !(REF_ATTRS & changes.keys).empty?
  end
  
  after_create do
    update_twitter_profile
  end
  
  before_destroy :delete_reference
  
  class << self

    def find_by_geocode(coordinates, radius_in_miles=20, limit=50)
      self.near(coordinates, radius_in_miles, :order => :distance).limit(limit)
    end

    def find_by_geocode_and_category(coordinates,category=LocationCategory::EatDrink)
      find_by_geocode(coordinates).where(:general_type => category.name)
    end

    def all_by_filters(options={})
      general_type = options[:general_type]
      radius       = options[:radius]
      coordinates  = options[:coordinates]
      name         = options[:name]
      order        = options[:order] || 'name'
      to_verify    = options[:to_verify] unless options[:to_verify].nil?
      to_geocode   = options[:to_geocode] unless options[:to_geocode].nil?

      relation = unscoped
      relation = relation.where(:general_type => general_type) if general_type
      relation = relation.where(arel_table[:name].matches(name)) if name
      relation = relation.where(:verified => false) if to_verify
      relation = relation.where(:latitude => nil) if to_geocode
      relation = relation.where(:active => options[:active]) unless options[:active].nil?
      if coordinates and !to_geocode
        order = "#{order},distance" unless order == 'distance'
        radius ||= 20
        relation = relation.near(coordinates, radius, :order => order)
      else
        relation = relation.order(order) if order != 'distance'
      end
      relation
    end

    def to_verify(older_than=60.days.ago)
      where("(verified_on ISNULL AND verified = false) OR verified_on < ?", older_than)
    end

    def favorite(id)
      location = find(id)
      location.update_attributes(:favorites_count => location.favorites_count + 1, :last_favorited_at => Time.now) if location
    end

  end

  def slugged_id
    "#{name} #{city}"
  end

  def categories
    [LocationCategory.find_by_name(general_type)]
  end

  # TODO implement
  def category_image_url
    general_category.icon
  end

  def general_category
    LocationCategory.find_by_name(general_type)
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
    !!(((Time.now - cached_twitter_status.created_at).abs < within) if cached_twitter_status)
  end

  def recent_twitter_mention?(within=1.day)
    !!(unless cached_twitter_mentions.empty?
      cached_twitter_mentions.any? { |tweet| 
        (Time.now - tweet.created_at).abs < within 
      }
    end)
  end
  
  def recent_twitter_mentions(within)
    cached_twitter_mentions.select { |tweet|
      (Time.now - tweet.created_at).abs < within
    }
  end

  def recent_twitter_status(within)
    if cached_twitter_status
      cached_twitter_status if (Time.now - cached_twitter_status.created_at).abs < within 
    end
  end

  def tweet_count(within=7.days)
    count = recent_twitter_mentions(within).length
    count += 1 if recent_twitter_status(within)
    count
  end

  def tweets(count=10)
    !twitter_name.blank? ? Tweet.latest(twitter_name,count) : []
  end

  def twitter_mentions(count=10)
    unless twitter?
      []
    else
      mentions = cached_twitter_mentions
      if mentions.empty?

        # nearby mentions
        mentions = Tweet.geosearch("@#{twitter_name}", coordinates, 5, count*2) # Fetch 2 times the count requested
        filtered = TweetFilter::Chain.new( TweetFilter::DuplicateText.new, TweetFilter::MentionCount.new(5) ).filter(mentions)

        # nearby with business name
        if filtered.length < count
          mentions = Tweet.geosearch( "\"#{name}\"", coordinates, 5, (count-filtered.length)*2 ) # Fetch 2 times the count requested
          filtered += TweetFilter::Chain.new( TweetFilter::DuplicateText.new, TweetFilter::MentionCount.new(5) ).filter(mentions)
          filtered.uniq!
        end

        # un-geo-tagged mentions
        if filtered.length < count
          mentions = Tweet.non_geosearch("@#{twitter_name}", (count-filtered.length)*2) # Fetch 2 times the count requested
          filtered += TweetFilter::Chain.new( TweetFilter::DuplicateText.new, TweetFilter::MentionCount.new(5) ).filter(mentions)
          filtered.uniq!
        end

        # un-geo-tagged by name
        if filtered.length < count
          mentions = Tweet.non_geosearch("\"#{name}\"", (count-filtered.length)*2) # Fetch 2 times the count requested
          filtered += TweetFilter::Chain.new( TweetFilter::DuplicateText.new, TweetFilter::MentionCount.new(5) ).filter(mentions)
          filtered.uniq!
        end

        filtered[0,count]
        self.cached_twitter_mentions = filtered
      end
      mentions || []
    end
  end

  def update_twitter_profile
    if twitter?
      begin
        res = Twitter.user twitter_name
        update_attributes({:profile_image_url => res.profile_image_url, :description => res.description})
        Rails.logger.info("Updated twitter profile for #{name}")
      rescue Twitter::Error => e
        Rails.logger.warn "Unable to update twitter profile for #{name}: #{e}"
      end
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

  def verified!(verifier='GooglePlaces')
    verify(true, verifier)
  end

  def unverified!(verifier='GooglePlaces')
    verify(false, verifier)
  end

  private

  def verify(mark, verifier='GooglePlaces')
    self.verified    = mark
    self.verified_by = verifier
    self.verified_on = Date.today
  end

  def cached_twitter_status
    twitter? ? Tweet.cached_user_status(twitter_name) : nil
  end

  def cached_twitter_mentions
    twitter? ? (Rails.cache.read(twitter_mentions_cache_key) || []) : []
  end

  def cached_twitter_mentions=(tweets)
    Rails.cache.write(twitter_mentions_cache_key, tweets, :expires_in => 15.minutes) if tweets && !tweets.empty?
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

  def twitter_mentions_cache_key
    "twitter:mentions:#{twitter_name}"
  end
  
end