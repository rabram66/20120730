require 'test_helper'

class TweetTest < ActiveSupport::TestCase
  
  setup do
    @location = locations(:one)
  end

  test "should return nil for latest when the user has not as tweeted" do
    stub_request(:get, "http://api.twitter.com/1/statuses/user_timeline.json?count=1&screen_name=someScreenName").
      with(:headers => {'Accept'=>'*/*; q=0.5, application/xml', 'Accept-Encoding'=>'gzip, deflate', 'User-Agent'=>'Ruby'}).
      to_return(:status => 200, :body => "[]", :headers => {})
    assert_nil Tweet.latest('someScreenName')
  end

end