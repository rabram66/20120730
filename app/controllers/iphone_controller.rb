require 'json'
require 'open-uri'
require 'builder'

class IphoneController < ApplicationController
  
  respond_to :xml
  layout false
  
  before_filter :set_coordinates, :only => [:index, :deals, :events]
  
  RADIUS = '750'
  DEFAULT_LOCATION = 'Atlanta, GA' 
  DEFAULT_COORDINATES = [33.7489954, -84.3879824] # Atlanta, GA
  
  def index
    category = params[:types].blank? ? LocationCategory::EatDrink : LocationCategory.find_by_name(params[:types])
    @locations = Location.find_by_geocode_and_category(@coordinates, category)
    @locations.reject! {|l| l.reference.nil? } # TODO: Remove this once reference can be gauranteed

    @places = Place.find_by_geocode(@coordinates, category.types)
    remove_duplicate_places unless @places.empty? || @locations.empty?

    @events = Event.upcoming_near(@coordinates)
    @deals = Deal.find_by_geocode(@coordinates)
    respond_with @places, @locations, @events, @deals, @coordinates
  end

  def deals
    respond_with(@deals = Deal.find_by_geocode(@coordinates))
  end

  def events
    respond_with(@events = Event.upcoming_near(@coordinates))
  end
 
  def iphone_details
    reference = params[:reference]        
    location = Location.find_by_reference(reference)  
    name, lat, lng, address, mentions, lastest_tweet, lastest_post = ""
    unless location.blank?
      name, lat, lng, address, mentions, lastest_tweet, lastest_post = get_loc_details(location) 
    else      
      details = get_place_response(reference) 
      name, lat, lng, address, mentions, lastest_tweet, lastest_post= get_place_details(details)
    end
    
    @output = ""
    builder = Builder::XmlMarkup.new(:target=> @output, :indent=>1)
    builder.instruct!
    builder.Business { |business|
      business.name name
      business.lat lat
      business.lng lng
      business.address address
     
      business.mentions { |metion|
        unless mentions.blank?
          mentions['results'].first(5).each do |m|
            metion.metion {|me|
              me.from_user m['from_user']
              me.profile_image_url m['profile_image_url']
              me.link_tweet "http://twitter.com/#{m['from_user']}/status/#{m['id_str']}"
              me.tweet m['text']
            }
          end
        end
      }
      lastest_tweet = lastest_tweet.first["text"].gsub("\n", " ") unless lastest_tweet.blank?
      business.advertise_url ''
      business.lastest_tweet lastest_tweet
      business.lastest_post lastest_post      
    }
    xml_res = builder.to_xml(:root => "BusinessList").gsub("<to_xml root=\"BusinessList\"/>", "")
    
    render :xml => xml_res
  end
  
  def get_loc_details(location)    
    return location.name,location.latitude, location.longitude, location.full_address, get_tweet_search(location.twitter_name), get_last_tweet(location.twitter_name), get_last_post(location)
  end
  
  def get_place_details(details)
    #name, lat, lng, address, mentions, lastest_tweet, lastest_post
    business = details["result"]
    return business['name'], business["geometry"]["location"]["lat"], business["geometry"]["location"]["lng"], business["formatted_address"], nil, nil, nil
  end
  
  def delete_place
    myarray = {:reference => params[:reference]}
    myarray = ActiveSupport::JSON.encode(myarray) 
    result = RestClient.post "https://maps.googleapis.com/maps/api/place/delete/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc", myarray, :content_type => :json, :accept => :json
    res = ActiveSupport::JSON.decode(result)
    
    xml_res = Array.new
    
    if res['status'].eql?("OK")
      xml_res += [:status => true]      
    else
      xml_res += [:status => false]
    end
    render :xml => xml_res
  end
  
  
  private

  def set_coordinates
    @coordinates = case
    when !params[:lat].blank? && !params[:lng].blank?
      [params[:lat].to_f, params[:lng].to_f]
    when !params[:address].blank?
      Geocoder.coordinates(params[:address])
    else
      DEFAULT_COORDINATES
    end
  end

  def remove_duplicate_places
    @places.reject! do |place| 
      exclude_place? place
    end
  end

  def exclude_place?(place)
    @locations.any? do |location| 
      place.name == location.name ||
      (!place.address.blank? && place.address.include?(location.address)) ||
      place.coordinates == location.coordinates
    end
  end
  
  def get_facebook_feed(facebook_page_id)
    begin
      # convert real name to id
      res_page = RestClient.get "https://graph.facebook.com/#{facebook_page_id}"
      result_page = ActiveSupport::JSON.decode(res_page) 
      
      facebook_link = "http://www.facebook.com/feeds/page.php?id=#{result_page["id"]}&format=json"
      res = RestClient.get facebook_link
      return ActiveSupport::JSON.decode(res)
    rescue
    end    
  end
  
  def get_twitter_feed(twitter_name)
    begin
      twitter_link = "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{twitter_name}"
      timeline = RestClient.get twitter_link
      return ActiveSupport::JSON.decode(timeline)
    rescue
    end
  end
  
  def get_place_report(location, long, lat)    
    myarray = {:location => {:lat => lat.to_f, :lng => long.to_f},
      :accuracy => 50, :name => location[:name], 
      :types => [location[:types]], :language => "en-AU"}
    json_string = myarray.to_json()    
    res = RestClient.post "https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc", json_string, :content_type => :json, :accept => :json    
    ActiveSupport::JSON.decode(res)
  end
  
  def get_place_response(reference)    
    HTTParty.get("https://maps.googleapis.com/maps/api/place/details/json?reference=#{reference}&sensor=true&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")
  end
  
  def get_last_post(location)    
    unless location.facebook_page_id.blank?
      # convert real name to id  
      id = location.facebook_page_id
      if is_real_name(location.facebook_page_id)
        res_page = RestClient.get "https://graph.facebook.com/#{location.facebook_page_id}"
        result_page = ActiveSupport::JSON.decode(res_page) 
        id = result_page["id"]
      end
      
      facebook_link = "http://www.facebook.com/feeds/page.php?id=#{id}&format=json"
      res = RestClient.get facebook_link
      results = ActiveSupport::JSON.decode(res)
      
      return results["entries"].first["title"] unless results["entries"].blank?
    end
  end
  
  def get_last_tweet(user_name)    
    timeline = RestClient.get "http://api.twitter.com/1/statuses/user_timeline.json?screen_name=#{user_name}&count=1"
    ActiveSupport::JSON.decode(timeline)    
  end
  
  def get_tweet_search(bussiness_name) 
    tweet = RestClient.get  "http://search.twitter.com/search.json?q=@#{bussiness_name.gsub(" ", "+")}&count=10"    
    ActiveSupport::JSON.decode(tweet)    
  end
  
  def is_real_name(name)
    name.to_i == 0? true : false
  end
  
  def eat_drink
    return ["bar", "cafe", "food", "restaurant"]
  end
  
  def relax_care
    ["amusement park", "aquarium", "art gallery", "beauty salon", "bowling alley",
      "casino", "gym", "hair care", "health", "movie theater", "museum", "night club", "park", "spa", "zoo"]
  end
  
  def shop_find
    ["atm", "bank", "bicycle store", "book store", "bus station", "clothing store", "convenience store" ,
      "department store", "electronics store", "establishment", "florist", "gas station", "grocery or supermarket",
      "hardware store", "home goods store", "jewelry store", "library", "liquor store", "locksmith", "pet store",
      "pharmacy", "shoe store", "shopping mall", "store"]
  end
  
end
