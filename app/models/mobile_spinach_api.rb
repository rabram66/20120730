class MobileSpinachApi

  API_KEY    = "fab85fc7989578768e3886aa9db7608a88a47724"
  APP_ID     = "233"
  LIST_URL   = "http://api.mobilespinach.com/rest/deals/?api_key=#{API_KEY}&appid=#{APP_ID}&state=activated&lat=%s&lng=%s&radius=%s"
  RADIUS     = 2 / Address::MILES_PER_KILOMETER # 2 miles in kilometers

  class << self

    def find_by_geocode(coordinates,radius=RADIUS)
      url = format(LIST_URL, coordinates.first, coordinates.last, radius)
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
        Deal.new(
          :source        => 'MobileSpinach',
          :title         => deal['title'],
          :description   => deal['description'],
          :name          => deal['merchant']['name'],
          :url           => deal['dip'],
          :mobile_url    => deal['dip'],
          :thumbnail_url => deal['images']['productimage']['thumbnail']['url'],
          :locations     => deal['merchant']['locations'].map { |l|
            loc = l['location']
            DealLocation.new(
              :address      => loc['address'], 
              :city         => loc['city'],
              :state        => loc['state'],
              :latitude     => loc['lat'],
              :longitude    => loc['lng'],
              :phone_number => loc['phonenumber']
            )
          }
        )
      end
    end

  end

end