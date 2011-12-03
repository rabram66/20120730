class Tweet
  USER_TIMELINE_URL = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=%s&count=%d"
  SEARCH_URL = "http://search.twitter.com/search.json?q=%s&count=%d"
  FOLLOW_URL = "http://twitter.com/%s/status/%s"  

  attr_reader :name, :screen_name, :text, :created_at, :profile_image_url, :tweet_id

  def initialize(attrs={})
    attrs.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
  end

  def follow_url
    format(FOLLOW_URL, screen_name, tweet_id)
  end
  
  class << self

    def latest(screen_name, count=1)
      api(USER_TIMELINE_URL, screen_name, count) do |response|
        if count == 1
          result = response.first
          transform_result( result ) if result
        else
          response.map { |result| transform_result( result ) }
        end
      end
    end
    
    def search(screen_name, count=10)
      tweets = api(SEARCH_URL, CGI.escape("@#{screen_name}"), count) do |response|
        response['results'][0,count].map do |result|
          Tweet.new(
            :name              => result['from_user_name'],
            :screen_name       => result['from_user'],
            :text              => result['text'],
            :created_at        => DateTime.parse( result['created_at'] ),
            :profile_image_url => result['profile_image_url'],
            :tweet_id          => result['id_str']
          )
        end
      end
    end

    private
    
    def api(url, *args)
      begin
        response = RestClient.get( format(url, *args) )
        yield ActiveSupport::JSON.decode(response)
      rescue RestClient::Exception => e
        Rails.logger.info("Twitter API failure: (#{e}) #{url}")
        nil
      end
    end
    
    def transform_result(result)
      Tweet.new( :name              => result['user']['name'],
                 :screen_name       => result['user']['screen_name'],
                 :text              => result['text'],
                 :created_at        => DateTime.parse( result['created_at'] ),
                 :profile_image_url => result['user']['profile_image_url'],
                 :tweet_id          => result['id_str']
      )
    end

  end
  
end
