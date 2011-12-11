class DealLocation
  include Address

  attr_accessor :address, :city, :state, :latitude, :longitude
  
  attr_reader :phone_number

  def initialize(attrs={})
    attrs.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
  end

end