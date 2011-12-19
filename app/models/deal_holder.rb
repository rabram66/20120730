module DealHolder
  def deals=(matched_deals)
    unless matched_deals.empty?
      Rails.cache.fetch("deals:#{name}", :expires_in => 1.day) do
        matched_deals.map {|deal| {:url => deal.url, :title => deal.title}}
      end
    end
  end

  def deals
    deal_data = Rails.cache.read("deals:#{name}")
    @deals = deal_data ? deal_data.map {|dd| Deal.new(dd) } : []
  end
  
  def deals?
    self.deals && self.deals.length > 0
  end
end