class Deal < ActiveRecord::Base
  attr_accessible :title, :description, :url, :mobile_url, :thumbnail_url, :provider, :provider_id,
                  :name, :locations, :source, :source_id, :start_date, :end_date, :deal_locations_attributes
  # extend FriendlyId
  
  include DatedModel

  has_many :deal_locations, :dependent => :delete_all
  alias_attribute :locations, :deal_locations
  accepts_nested_attributes_for :deal_locations

  validates_presence_of :start_date, :end_date, :name, :title

  scope :current, where("(start_date ISNULL AND end_date ISNULL) OR (start_date >= :today OR end_date >= :today)", {:today => Date.today})

  class << self
    def near(coordinates, radius)
      Deal.current.joins(:deal_locations).select('deals.*').merge( DealLocation.near(coordinates,2) )
    end
  end

  def match?(location)
    name_match?(location) || locations_match?(location)
  end

  private

  def locations_match?(location)
    locations.any? do |deal_location| 
      deal_location.phone_match?(location)
    end
  end

  def name_match?(location)
    unless name.blank? || location.name.blank?
      name.include? location.name
    end
  end
                  
end
