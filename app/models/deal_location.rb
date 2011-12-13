class DealLocation
  include Address

  attr_accessor :address, :city, :state, :latitude, :longitude
  
  attr_reader :phone_number

  def initialize(attrs={})
    attrs.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
  end

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