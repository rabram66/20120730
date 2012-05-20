class DealSet
  include Enumerable
  attr_accessor :deals

  alias_attribute :length, :count
  
  def initialize(deals)
    @deals = deals
  end
  
  class << self
    def find_by_geocode(coordinates)
      yipit_deals = YipitApi.find_by_geocode(coordinates)
      mobile_spinach_deals = MobileSpinachApi.find_by_geocode(coordinates)
      new(mobile_spinach_deals + yipit_deals)
    end
  end

  def each
    @deals.each{ |deal| yield deal }
  end

  def matching_deals?(location)
    !matching_deals(location).empty?
  end

  def matching_deals(location)
    deals.select do |deal|
      deal.match?(location)
    end
  end

end