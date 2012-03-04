class UrlShortener
  attr_reader :service

  def initialize
    Bitly.use_api_version_3
    @service = Bitly.new("nearbythis",Rails.application.config.app.bitly_api_key)
  end
  
  case Rails.env
  when 'production'
    def shorten(url)
      service.shorten(url).short_url
    end
  else
    def shorten(url)
      url
    end
  end
end