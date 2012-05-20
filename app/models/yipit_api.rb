class YipitApi

  API_KEY  = "zZnf9zms8Kxp6BPE"
  LIST_URL = "http://api.yipit.com/v1/deals/?key=#{API_KEY}&lat=%s&lon=%s&radius=%s"
  DEAL_URL = "http://api.yipit.com/v1/deals/?key=#{API_KEY}&phone=%s"
  RADIUS   = 2

  class << self

    def find_by_geocode(coordinates,radius=RADIUS)
      url = format(LIST_URL, coordinates.first, coordinates.last, radius)
      deals = []
      begin
        response = RestClient.get url, {:accept => :json}
        deals =  transform_response(ActiveSupport::JSON.decode(response))
      rescue RestClient::Exception => e
        Rails.logger.info("Yipit API failure: (#{e}) #{url}")
      end
      deals
    end

    def find_by_phone(phone)
      deals = []
      unless phone.blank?
        url = format(DEAL_URL, phone.gsub(/[^0-9]/,''))
        begin
          response = RestClient.get url, {:accept => :json}
          deals =  transform_response(ActiveSupport::JSON.decode(response))
        rescue RestClient::Exception => e
          Rails.logger.info("Yipit API failure: (#{e}) #{url}")
        end
      end
      DealSet.new(deals)
    end

    private
    
    def transform_response(res)
      if res['response'] && res['response']['deals']
        res['response']['deals'].map do |deal|
          Deal.new(
            :source        => 'Yipit',
            :title         => deal['yipit_title'],
            :description   => deal['title'],
            :name          => deal['business']['name'],
            :url           => deal['url'],
            :mobile_url    => deal['mobile_url'],
            :thumbnail_url => deal['images']['image_small'],
            :locations     => deal['business']['locations'].map { |l|
              DealLocation.new(
                :address      => l['address'], 
                :city         => l['locality'],
                :state        => l['state'],
                :latitude     => l['lat'],
                :longitude    => l['lon'],
                :phone_number => l['phone']
              )
            }
          )
        end
      else
        []
      end
    end

  end

end