class DealSet
  
  attr_accessor :deals
  
  def initialize(deals)
    @deals = deals
  end

  def find_by_phone_number(phone_number)
    phone_number.gsub!(/[^0-9]/,'')
    deals.select do |deal|
      deal.locations.collect {|l| l.phone_number.gsub(/[^0-9]/,'') unless l.phone_number.blank?}.include?(phone_number)
    end
  end
end