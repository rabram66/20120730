class Deal

  attr_reader :title, :description, :url, :mobile_url, :thumbnail_url, 
              :latitude, :longitude, :name, :locations, :source

  def initialize(attrs={})
    attrs.each do |k,v|
      instance_variable_set("@#{k}", v)
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