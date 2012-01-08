require 'test_helper'

class TweetTest < ActiveSupport::TestCase

  setup do
    @location = locations(:one)
  end

  def ratelimit_headers
    {
      'X-RateLimit-Class'     => 'api',
      'X-RateLimit-Remaining' => 0,
      'X-RateLimit-Reset'     => 1323202863,
      'X-RateLimit-Limit'     => 150
    }
  end

  should "return nil for latest when the user has not as yet tweeted" do
    stub_request(:get, "http://api.twitter.com/1/statuses/user_timeline.json?count=1&screen_name=someScreenName&include_entities=1").
      with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "[]", :headers => {})
    assert_nil Tweet.latest('someScreenName')
  end

  should "use the screen name for the twitter page url" do
    tweet = Tweet.new(:screen_name => 'gpburdell')
    assert_equal "http://twitter.com/gpburdell", tweet.twitter_page_url
  end

  should "use the screen name and tweet id for the follow url" do
    tweet = Tweet.new(:screen_name => 'gpburdell', :tweet_id => 12345)
    assert_equal "http://twitter.com/gpburdell/status/12345", tweet.follow_url
  end

  context 'with hashtags' do
    should 'indicate that its for a deal' do
      tweet = Tweet.new(:hashtags => ['deal','schmeal'])
      assert tweet.deal?
    end
    should 'indicate that its not for a deal' do
      tweet = Tweet.new(:hashtags => ['feal','schmeal'])
      assert !tweet.deal?
    end
  end

end