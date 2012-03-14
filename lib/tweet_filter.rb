module TweetFilter
  
  module EachTweet
    def apply(tweets=[])
      tweets.reject do |tweet|
        yield tweet
      end
    end
  end

  class Chain
    
    def initialize(*filters)
      @filters = filters
    end
    
    def filter(tweets)
      tweets ||= []
      @filters.inject(tweets) do |tweets, filter|
        filter.filter(tweets)
      end
    end

  end
  
  # Filter tweets that have a least a certain number of mentions
  class MentionCount

    include EachTweet
    attr_reader :count, :except

    def initialize(count, options={})
      @except = options[:except] && "@#{options[:except]}"
      @count = count
    end

    def filter(tweets=[])
      apply(tweets) do |tweet|
        mentions = tweet.text.scan(/@\w+/)
        mentions.reject! {|mentioner| mentioner.downcase == except.downcase} if except
        mentions.length >= count
      end
    end

  end

  # Filter tweets that have a least a certain number of hashtags
  class HashtagCount

    include EachTweet
    attr_reader :count, :except

    def initialize(count, options={})
      @except = options[:except]
      @count = count
    end

    def filter(tweets=[])
      apply(tweets) do |tweet|
        hashtags = tweet.hashtags
        hashtags.reject! {|tag| tag.downcase == except.downcase} if except
        hashtags.length >= count
      end
    end

  end

  # Remove duplicates based on the text of the tweet
  class DuplicateText
    def filter(tweets=[])
      Hash[ tweets.map { |tweet| [tweet.text, tweet] } ].values
    end
  end

end