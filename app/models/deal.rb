class Deal

  API_KEY = "zZnf9zms8Kxp6BPE"
  YIPIT_URL = "http://api.yipit.com/v1/deals/?key=#{API_KEY}&lat=%s&lon=%s"

  class << self
    def find_by_geocode(geocode)
      url = format(YIPIT_URL, geocode.first, geocode.last)
      response = HTTParty.get(url)
      deals = []
      if response.code == 200
        res = ActiveSupport::JSON.decode(response.parsed_response)
        if res['response'] && res['response']['deals']
          deals = res['response']['deals'].map do |deal|
            puts deal.inspect
            Deal.new()
          end
        end
      else
        Rails.logger.error "Unable to retrieve deals: (#{response.code}) #{url}"
      end
      deals
    end
  end
end

# def load_deals
#   #get deals from yipit
#   begin
#     lat, lon = cookies[:address].split("&")
#     deals = RestClient.get "http://api.yipit.com/v1/deals/?key=zZnf9zms8Kxp6BPE&lat=#{lat}&lon=#{lon}"
#     deals = Hash.from_xml(deals).to_json
#     @deals = ActiveSupport::JSON.decode(deals)
#   rescue
#   end
#   
#   render :partial => 'deals', :layout => false
# end
