class Deal < ActiveRecord::Base
  attr_accessible :title, :description, :url, :mobile_url, :thumbnail_url, 
                  :name, :locations, :source, :source_id, :start_date, :end_date

  has_many :deal_locations, :dependent => :destroy
  alias_attribute :locations, :deal_locations
                  
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
