class DealSet
  include Enumerable
  attr_accessor :deals

  alias_attribute :length, :count
  
  MIN_DEALS = 4
  
  def initialize(deals)
    @deals = deals
  end
  
  class << self
    def near(coordinates)
      deals = Deal.near(coordinates, 2)
      if deals.count < MIN_DEALS
        DealImporter.new(coordinates).delay.import
      end
      new(deals)
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