# Facebook wall post
class WallPost

  #TODO Replace with NearbyThis access token
  ACCESS_TOKEN = "AAACEdEose0cBAESXdzrNUwmu4vigIauClbKgGjkQVDdzUfn4TJMtoRFXkfKlKtUNTxwJZAJdChG9jPWSpgmDUZCH6RRbJuSxTItplrZBAZDZD"

  WALL_POST_URL = "https://graph.facebook.com/%s/feed?limit=%d&access_token=#{ACCESS_TOKEN}"

  attr_accessor :message
  
  def initialize(message)
    @message = message
  end

  class << self
    
    def latest(facebook_id)
      posts =  feed(facebook_id)
      posts.first unless posts.blank?
    end

    def feed (facebook_id,limit=1)
      url = format(WALL_POST_URL, facebook_id, limit) 
      res = HTTParty.get( url )
      if res.code == 200 && res.parsed_response['data']
        res.parsed_response['data'].map do |post|
          WallPost.new(:message => post['message'])
        end
      else
        Rails.logger.error "Unable to retrieve Facebook feed: (#{res.code}) #{url}"
        []
      end
    end

  end

end