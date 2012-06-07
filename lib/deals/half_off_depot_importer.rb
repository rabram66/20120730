module Deals
  class HalfOffDepotImporter
    def import
      results = HalfOffDepotApi.search_all_cities

      # Remove all HalfOffDepot deals
      provider = 'HalfOffDepot'
      DealLocation.for_provider( provider ).delete_all
      Deal.delete_all(['provider = ?', provider])

      results.each do |city, deals|
        deals.each do |deal|
          Deal.create(deal)
        end
      end

    end
  end
end