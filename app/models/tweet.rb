class Tweet
  USER_TIMELINE_URL = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=%s&count=%d&include_entities=1"
  SEARCH_URL = "http://search.twitter.com/search.json?q=%s&page=1&rpp=%d&include_entities=1"
  GEOSEARCH_URL = "http://search.twitter.com/search.json?q=%s&geocode=%s&page=1&rpp=%d&include_entities=1"
  FOLLOW_URL = "http://twitter.com/%s/status/%s"  
  RADIUS = 5 # radius of search in miles for tweets search

  attr_reader :name, :screen_name, :text, :created_at, :profile_image_url, :tweet_id, :hashtags

  def initialize(attrs={})
    attrs.each do |k,v|
      instance_variable_set("@#{k}", v)
    end
  end

  def follow_url
    format(FOLLOW_URL, screen_name, tweet_id)
  end

  def twitter_page_url
    "http://twitter.com/#{screen_name}"
  end

  # True if the status text contains a #deal hashtag
  def deal?
    hashtags.any?{ |tag| tag.downcase == 'deal' }
  end

  def ==(other)
    other.class == self.class && other.tweet_id  == self.tweet_id
  end

  alias :eql? :==

  def hash
    "#{self.class}:#{self.tweet_id}".hash
  end
  
  class << self
    
    # 1. Search in Rails.cache for latest tweet for a given screen name
    # 2. If found in cache
    #   2.1 Return cache value
    # 3. If not found in cache
    #   2.1 Get the Twitter REST API rate info from Rails.cache
    #   2.2 If found and the current time is before the reset time and the rate limit remaining is zero:
    #     2.2.1 Stop
    #   2.3 Otherwise
    #     2.1 Fetch latest status from twitter
    #       2.1.1 If 200, store status in Rails.cache 
    #             with expiry set to 2 hours +- 60 minutes
    #       2.1.2 Store the Twitter REST API Rate Limit info in Rails cache

    def cached_user_status(screen_name)
      Rails.cache.read status_cache_key(screen_name)
    end
    
    def cached_mentions(screen_name)
      Rails.cache.read mention_cache_key(screen_name)
    end
    
    def cached_searches(query)
      Rails.cache.read search_cache_key(screen_name)
    end

    def user_status(screen_name)
      cache_key = status_cache_key(screen_name)
      tweet = Rails.cache.read(cache_key)
      unless tweet
        ratelimit = read_ratelimit(:api)
        if !ratelimit || !ratelimit.exceeded?
          tweet = latest(screen_name)
          Rails.cache.write(cache_key, tweet, :expires_in => 1.hour) if tweet
        end
      end
      tweet
    end
    
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

    def mentions(screen_name, count=10)
      search("@#{screen_name}", count)
    end

    def geosearch(query, coordinates, radius=5, count=10)
      geocode = "#{[coordinates.first, coordinates.last, radius].join(',')}mi"
      api(GEOSEARCH_URL, CGI.escape(query), geocode, count) do |response|
        response['results'][0,count].map do |result|
          transform_search_result result
        end
      end
    end

    def non_geosearch(query, count=10)
      api(SEARCH_URL, CGI.escape(query), count) do |response|
        response['results'][0,count].map do |result|
          transform_search_result result
        end
      end
    end

    # TODO: Factor out caching as was done with #geosearch
    def search(query, count=10)
      cache_key = "twitter:search:#{query}"
      cached_tweets = Rails.cache.read(cache_key)
      unless cached_tweets
        tweets = api(SEARCH_URL, CGI.escape(query), count) do |response|
          response['results'][0,count].map do |result|
            transform_search_result result
          end
        end
        if tweets
          Rails.cache.write(cache_key, tweets, :expires_in => 15.minutes)
          cached_tweets = tweets
        end
      end
      cached_tweets || []
    end

    private

    def status_cache_key(screen_name)
      "twitter:status:#{screen_name}"
    end

    def mention_cache_key(screen_name)
      search_cache_key "@#{screen_name}"
    end
    
    def search_cache_key(query)
      "twitter:search:#{query}"
    end
    
    def api(url, *args)
      url = format(url, *args)
      begin
        Rails.logger.info("Twitter fetch: #{url}")
        response = RestClient.get(url)
        write_ratelimit(response)
        yield ActiveSupport::JSON.decode(response)
      rescue RestClient::Exception => e
        # HoptoadNotifier.notify e, :error_message => "Twitter API failure: (#{e}) #{url}"
        Rails.logger.info("Twitter API failure from #{`hostname`.strip}: (#{e}) #{url}: #{e.http_body}")
        nil
      end
    end

    def write_ratelimit(response)
      ratelimit = parse_ratelimit(response.headers)
      Rails.cache.write("twitter:ratelimit:#{ratelimit.api_class}:#{`hostname`.strip}", ratelimit.to_hash) if ratelimit
    end
    
    def read_ratelimit(api_class)
      ratelimit = Rails.cache.read("twitter:ratelimit:#{api_class}:#{`hostname`.strip}")
      ::Twit::RateLimit.new(ratelimit) if ratelimit
    end
    
    def parse_ratelimit(headers)
      unless headers[:x_ratelimit_class].blank?
        ::Twit::RateLimit.new(
          :api_class  => headers[:x_ratelimit_class].to_sym,
          :limit      => headers[:x_ratelimit_limit].to_i,
          :remaining  => headers[:x_ratelimit_remaining].to_i,
          :reset_time => headers[:x_ratelimit_reset].to_i
        )
      end
    end
      
    
    def transform_result(result)
      Tweet.new( :name              => result['user']['name'],
                 :screen_name       => result['user']['screen_name'],
                 :text              => result['text'],
                 :created_at        => DateTime.parse( result['created_at'] ),
                 :profile_image_url => result['user']['profile_image_url'],
                 :tweet_id          => result['id_str'],
                 :hashtags          => (result['entities']['hashtags'] || []).map{|tag| tag['text']}
      )
    end

    def transform_search_result(result)
      Tweet.new(
        :name              => result['from_user_name'],
        :screen_name       => result['from_user'],
        :text              => result['text'],
        :created_at        => DateTime.parse( result['created_at'] ),
        :profile_image_url => result['profile_image_url'],
        :tweet_id          => result['id_str'],
        :hashtags          => ((result['entities'] || {})['hashtags'] || []).map{|tag| tag['text']}
      )
    end

  end
  
end
