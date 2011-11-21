class Deal

  API_KEY = "zZnf9zms8Kxp6BPE"
  YIPIT_URL = "http://api.yipit.com/v1/deals/?key=#{API_KEY}&lat=%s&lon=%s"

  attr_reader :title, :yipit_url

  def initialize(attrs={})
    attrs.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
  end

  class << self

    def find_by_geocode(geocode)
      url = format(YIPIT_URL, geocode.first, geocode.last)
      response = HTTParty.get(url)
      deals = []
      if response.code == 200
        res = ActiveSupport::JSON.decode(response.parsed_response)
        if res['response'] && res['response']['deals']
          deals = res['response']['deals'].map do |deal|
            Deal.new(:title => deal['title'], :yipit_url => deal['url'])
          end
        end
      else
        Rails.logger.error "Unable to retrieve deals: (#{response.code}) #{url}"
      end
      deals
    end

  end

end