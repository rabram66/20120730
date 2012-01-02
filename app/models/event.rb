class Event < ActiveRecord::Base

  include Address

  ADDRESS_ATTRS = %w(city state address)
  CATEGORIES =  %w(conference conventions entertainment fundraisers meetings other performances reunions sales seminars social sports tradeshows travel religion fairs food music recreation)

  validates_presence_of :name, :address, :city, :state, :description
  attr_accessible :name, :address, :city, :state, :description,
                  :latitude, :longitude, :user_id, :full_address, :start_date,
                  :tags, :end_date, :venue, :category
  validates :category, :inclusion => {:in => CATEGORIES, :allow_blank => true}

  belongs_to :user
  geocoded_by :full_address

  scope :upcoming, where("(start_date ISNULL AND end_date ISNULL) OR (start_date >= :today OR end_date >= :today)", {:today => Date.today})

  before_save :parse_dates
  
  # before_save do
  #   puts "before_save: End date: #{self.end_date}"
  # end
  # 
  # after_save do
  #   puts "after_save: End date: #{self.end_date}"
  # end
  
  after_validation do
    geocode if !(ADDRESS_ATTRS & changes.keys).empty? || latitude.blank? || longitude.blank?
    normalize_tags unless tags.blank?
  end

  def full_address=(value)
    parse_full_address(value)
  end

  def tweets(count=10)
    hashtags = tags.blank? ? [] : tags.split
    query = (["\"#{name}\""] + hashtags).join ' OR '
    tweets = Tweet.search(query, count*2)
    filtered = TweetFilter::Chain.new( TweetFilter::DuplicateText.new, TweetFilter::HashtagCount.new(5), TweetFilter::MentionCount.new(5), ).filter(tweets)
    filtered[0,count]
  end

  class << self
    def find_by_geocode(coordinates)
      self.near(coordinates, 2, :order => :distance)
    end
    def upcoming_near(coordinates)
      upcoming.find_by_geocode(coordinates).order(:start_date)
    end
  end

  private
  
  def parse_dates
    self.start_date = Chronic::parse(start_date_before_type_cast) unless start_date_before_type_cast.blank?
    unless end_date_before_type_cast.blank?
      parsed_date = Chronic::parse(end_date_before_type_cast)
      date = Time.new(start_date.year, start_date.month, start_date.day, end_date.hour, end_date.min, end_date.sec, end_date.utc_offset)
      self.end_date = date < start_date ? date + 1.day : date
    end
  end

  def normalize_tags
    unless tags.blank?
      # append hash character if needed
      with_hash = tags.split(/[^#A-Za-z0-9]/).map{|t| t.starts_with?('#') ? t : "##{t}"}
      self.tags = with_hash.join(' ')
    end
  end

end
