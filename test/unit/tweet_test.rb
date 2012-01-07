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
    
  test "should return nil for latest when the user has not as yet tweeted" do
    stub_request(:get, "http://api.twitter.com/1/statuses/user_timeline.json?count=1&screen_name=someScreenName&include_entities=1").
      with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "[]", :headers => {})
    assert_nil Tweet.latest('someScreenName')
  end

end