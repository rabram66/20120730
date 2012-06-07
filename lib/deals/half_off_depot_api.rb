module Deals
  class HalfOffDepotApi

    NO_END_DATE = '2999-01-01' # In anticipation of the Y3K problem
    API_KEY  = "33596"
    SEARCH_URL = "https://api.halfoffdepot.com/affiliate/v1/?mpid=#{API_KEY}&format=json&city=%s"

    class << self
      
      def cities
        %w(atlanta knoxville nashville orlando tampabay charlotte jacksonville)
      end

      def search_all_cities
        cities.inject({}) { |h, city| h.store(city, search(city)); h }
      end

      def search(city)
        url = format(SEARCH_URL, city)
        deals = []
        begin
          response = RestClient.get url, {:accept => :json}
          deals =  transform_response(ActiveSupport::JSON.decode(response))
        rescue RestClient::Exception => e
          Rails.logger.info("HalfOffDepot API failure: (#{e}) #{url}")
        end
        deals
      end

      private
    
      def transform_response(res)
        if res['deals']
          res['deals'].values.map do |deal|
            {
              :provider      => 'HalfOffDepot',
              :provider_id   => deal['id'],
              :source        => 'HalfOffDepot',
              :title         => deal['title'],
              :description   => deal['description'],
              :name          => deal['brand'],
              :url           => deal['deal_url'],
              :mobile_url    => deal['deal_url'],
              :thumbnail_url => deal['small_image_url'],
              :start_date    => deal['start_date'],
              :end_date      => deal['end_date'] || NO_END_DATE,
              :deal_locations_attributes => [{
                :address      => deal['address'], 
                :city         => deal['city'],
                :state        => deal['state'],
                :phone_number => deal['phone']
              }]
            }
          end
        else
          []
        end
      end

    end
  end
end