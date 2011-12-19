class Deal

  API_KEY = "zZnf9zms8Kxp6BPE"
  YIPIT_URL = "http://api.yipit.com/v1/deals/?key=#{API_KEY}&lat=%s&lon=%s&radius=%s"
  YIPIT_PHONE_URL = "http://api.yipit.com/v1/deals/?key=#{API_KEY}&phone=%s"
  RADIUS = 2

  attr_reader :title, :description, :url, :mobile_url, :thumbnail_url, 
              :latitude, :longitude, :name, :locations

  def initialize(attrs={})
    attrs.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
  end
  
  def match?(location)
    name_match?(location) || locations_match?(location)
  end

  class << self

    def find_by_geocode(coordinates,radius=RADIUS)
      url = format(YIPIT_URL, coordinates.first, coordinates.last, radius)
      deals = []
      begin
        response = RestClient.get url, {:accept => :json}
        deals =  transform_response(ActiveSupport::JSON.decode(response))
      rescue RestClient::Exception => e
        Rails.logger.info("Yipit API failure: (#{e}) #{url}")
      end
      DealSet.new(deals)
    end

    def find_by_phone(phone)
      deals = []
      unless phone.blank?
        url = format(YIPIT_PHONE_URL, phone.gsub(/[^0-9]/,''))
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

  private

  def locations_match?(location)
    locations.any? do |deal_location| 
      deal_location.phone_match?(location) || deal_location.address_match?(location)
    end
  end
  
  def name_match?(location)
    unless name.blank? || location.name.blank?
      name.include? location.name
    end
  end

end