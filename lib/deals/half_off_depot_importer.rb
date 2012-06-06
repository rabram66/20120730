module Deals
  class HalfOffDepotImporter
    def import
      results = HalfOffDepotApi.search_all_cities
      results.each do |city, deals|
        deals.each do |deal|
          Deal.create(deal) unless Deal.find_by_provider_and_provider_id(deal[:provider], deal[:provider_id].to_s)
        end
      end
    end
  end
end