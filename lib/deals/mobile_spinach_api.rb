module Deals
  class MobileSpinachApi

    API_KEY    = "fab85fc7989578768e3886aa9db7608a88a47724"
    APP_ID     = "233"
    SEARCH_URL   = "http://api.mobilespinach.com/rest/deals/?api_key=#{API_KEY}&appid=#{APP_ID}&state=activated&lat=%s&lng=%s&radius=%s"
    RADIUS     = 2 / Address::MILES_PER_KILOMETER # 2 miles in kilometers

    class << self

      def geosearch(coordinates,radius=RADIUS)
        url = format(SEARCH_URL, coordinates.first, coordinates.last, radius)
        deals = []
        begin
          response = RestClient.get url, {:accept => :json}
          deals =  transform_response(ActiveSupport::JSON.decode(response))
        rescue RestClient::Exception => e
          Rails.logger.info("MobileSpinach API failure: (#{e}) #{url}")
        end
        deals
      end

      private
    
      def transform_response(res)
        res.map do |deal|
          {
            :provider      => 'MobileSpinach',
            :provider_id   => deal['id'],
            :title         => deal['title'],
            :description   => deal['description'],
            :name          => deal['merchant']['name'],
            :url           => deal['dip'],
            :mobile_url    => deal['dip'],
            :thumbnail_url => deal['images']['productimage']['thumbnail']['url'],
            :start_date    => deal['startdate'],
            :end_date      => deal['enddate'],
            :deal_locations_attributes => deal['merchant']['locations'].map { |l|
              loc = l['location']
              {
                :address      => loc['address'], 
                :city         => loc['city'],
                :state        => loc['state'],
                :latitude     => loc['lat'],
                :longitude    => loc['lng'],
                :phone_number => loc['phonenumber']
              }
            }
          }
        end
      end

    end

  end
end