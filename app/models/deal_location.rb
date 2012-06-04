class DealLocation < ActiveRecord::Base
  include Address
  attr_accessible :address, :city, :state, :latitude, :longitude
  belongs_to :deal
  
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
