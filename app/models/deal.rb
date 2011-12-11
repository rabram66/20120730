class Deal

  API_KEY = "zZnf9zms8Kxp6BPE"
  YIPIT_URL = "http://api.yipit.com/v1/deals/?key=#{API_KEY}&lat=%s&lon=%s"

  attr_reader :title, :description, :url, :mobile_url, :thumbnail_url, 
              :latitude, :longitude, :name, :locations

  def initialize(attrs={})
    attrs.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
  end

  class << self

    def find_by_phone_number
    end

    def find_by_geocode(coordinates)
      url = format(YIPIT_URL, coordinates.first, coordinates.last)
      deals = []
      begin
        response = RestClient.get url, {:accept => :json}
        res = ActiveSupport::JSON.decode(response)
        if res['response'] && res['response']['deals']
          deals = res['response']['deals'].map do |deal|
            Deal.new(
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
        end
      rescue RestClient::Exception => e
        Rails.logger.info("Yipit API failure: (#{e}) #{url}")
      end
      deals
    end

  end

end