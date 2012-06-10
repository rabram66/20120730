module Deals
  class ScoutmobApi

    SEARCH_URL = "http://scoutmob.com/%s.rss"

    class << self
      
      def cities
        %w( atlanta austin boston chicago dallas denver los-angeles 
            nashville new-york portland san-francisco seattle washington-dc )
      end

      def search_all_cities
        cities.inject({}) { |h, city| h.store(city, search(city)); h }
      end

      def search(city)
        url = format(SEARCH_URL, city)
        deals = []
        begin
          response = RestClient.get url
          parsed_response = Nokogiri::XML::Document.parse(response.body)
          deals =  parsed_response.xpath('//item').map do |item|
            transform_item(item)
          end
        rescue RestClient::Exception => e
          Rails.logger.info("ScoutMob API failure: (#{e}) #{url}")
        end
        deals
      end

      private
    
      def transform_item(item)
        {
          :provider      => 'Scoutmob',
          :provider_id   => item.xpath('guid').text,
          :source        => 'Scoutmob',
          :title         => item.xpath('title').text,
          :description   => item.xpath('description').text,
          :name          => item.xpath('location').text,
          :url           => item.xpath('link').text,
          :mobile_url    => item.xpath('link').text,
          :thumbnail_url => item.xpath('image').text,
          :start_date    => item.xpath('pubDate').text,
          :end_date      => item.xpath('siteEndDate').text,
          :deal_locations_attributes => [{
            :address      => item.xpath('address').text, 
            :city         => item.xpath('city').text,
            :state        => item.xpath('state').text,
            :phone_number => item.xpath('phone').text,
            :latitude     => item.xpath('latitude').text,
            :longitude    => item.xpath('longitude').text
          }]
        }
      end

    end
  end
end