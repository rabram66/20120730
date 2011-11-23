# Facebook wall post
class WallPost

  FEED_URL = "http://www.facebook.com/feeds/page.php?format=json&id=%s"

  attr_accessor :text, :facebook_post_url
  
  def initialize(text, facebook_post_url)
    @text, @facebook_post_url = text, facebook_post_url
  end

  class << self
    
    def latest(facebook_id)
      posts = feed(facebook_id)
      posts.first unless posts.blank?
    end

    def feed(facebook_id)
      results = []

      url = format(FEED_URL, facebook_id) 
      response = RestClient.get( url )

      if response.code == 200
        begin
          result = ActiveSupport::JSON.decode(response.body)
          if result['link'].nil? || result['entries'].nil?
            Rails.logger.error "Unexpected response body: (#{result}) #{url}"
          else
            results = result['entries'].reject{|e| e['title'].strip.blank?}.map do |entry|
              WallPost.new(entry['title'].strip, entry['alternate'])
            end
          end
        rescue MultiJson::DecodeError => e
          Rails.logger.error "Exception: #{e}: #{url}"
        end
      else
        Rails.logger.error "Unable to retrieve Facebook feed: (#{response.code}) #{url}"
      end
      results
    end

  end

end