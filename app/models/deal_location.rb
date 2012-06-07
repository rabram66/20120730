class DealLocation < ActiveRecord::Base
  include Address
  attr_accessible :address, :city, :state, :latitude, :longitude, :phone_number

  belongs_to :deal

  geocoded_by :full_address

  ADDRESS_ATTRS = %w(city state address)

  after_validation do
    geocode if !(ADDRESS_ATTRS & changes.keys).empty? || latitude.blank? || longitude.blank?
  end

  scope :for_provider, lambda { |provider|
    where("deal_id IN (#{select('deal_id').joins(:deal).where(['deals.provider = ?', provider]).to_sql})")
  }
  
  def phone_match?(location)
    unless phone_number.blank? || location.phone_number.blank?
      phone_number.gsub(/[^0-9]/,'') == location.phone_number.gsub(/[^0-9]/,'')
    end
  end
  
  def address_match?(location)
    unless address.blank? || location.address.blank?
      address.include? location.address
    end
  end
  
end
