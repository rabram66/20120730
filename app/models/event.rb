class Event < ActiveRecord::Base

  include Address

  ADDRESS_ATTRS = %w(city state address)
  CATEGORIES =  %w(conference conventions entertainment fundraisers meetings other performances reunions sales seminars social sports tradeshows travel religion fairs food music recreation)

  validates_presence_of :name, :address, :city, :state, :description
  attr_accessible :name, :address, :city, :state, :description,
                  :latitude, :longitude, :user_id, :full_address, :start_date,
                  :tags, :end_date
  validates :category, :inclusion => {:in => CATEGORIES, :allow_blank => true}

  belongs_to :user
  geocoded_by :full_address

  scope :upcoming, where("(start_date ISNULL AND end_date ISNULL) OR (start_date >= :today OR end_date >= :today)", {:today => Date.today})
  
  after_validation do 
    geocode if !(ADDRESS_ATTRS & changes.keys).empty? || latitude.blank? || longitude.blank?
  end

  before_save :parse_dates
  
  def full_address=(value)
    parse_full_address(value)
  end

  def tweets(count=10)
    hashtags = tags.blank? ? [] : tags.split(/\W/).map{|t| t.starts_with?('#') ? t : "##{t}"}
    query = (["\"#{name}\""] + hashtags).join ' OR '
    tweets = Tweet.search(query, count*2)
    filtered = TweetFilter::Chain.new( TweetFilter::DuplicateText.new, TweetFilter::MentionCount.new(5) ).filter(tweets)
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
    self.start_date = Chronic::parse(start_date_before_type_cast) 
    unless end_date_before_type_cast.blank?
      # If only time was passed; set date to date of start_date
      date_to_parse = end_date_before_type_cast =~ /^\d?\d\:\d\d\s?(am|pm)$/i ? "#{self.start_date.to_date.to_s} #{end_date_before_type_cast}" : end_date_before_type_cast
      self.end_date = Chronic::parse(date_to_parse)
    end
  end

end
