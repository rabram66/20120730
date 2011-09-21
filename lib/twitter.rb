require 'rubygems'
require 'httparty'

class Twitter
  include HTTParty
  base_uri 'twitter.com'
  basic_auth 'nearbythis', '613600'
end

puts Twitter.post('/statuses/update.json', :query => {:status => "Sweet!"}).inspect
#