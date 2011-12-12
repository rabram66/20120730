class DealSet
  include Enumerable
  attr_accessor :deals

  alias_attribute :length, :count
  
  def initialize(deals)
    @deals = deals
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