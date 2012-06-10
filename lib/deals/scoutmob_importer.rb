module Deals
  class ScoutmobImporter
    def import
      results = ScoutmobApi.search_all_cities

      # Remove all prior deals
      provider = 'Scoutmob'
      DealLocation.for_provider( provider ).delete_all
      Deal.delete_all(['provider = ?', provider])

      results.each do |city, deals|
        deals.each do |deal|
          # Scoutmob deals have lat/lng, do disable geocoding in the after_validation callback
          Deal.new(deal).save(:validate => false)
        end
      end

    end
  end
end