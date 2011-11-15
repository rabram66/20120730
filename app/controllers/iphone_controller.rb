include Geokit::Geocoders
require 'json'
require 'open-uri'
require 'builder'

class IphoneController < ApplicationController
  
  respond_to :html, :xml, :json, :js
  layout false
  
  RADIUS = '750'  
  DEFAULT_LOCATION = 'Atlanta, GA' 
  
  def iphone
    coordinates = ""
    if !params[:lat].blank? && !params[:lng].blank?
      coordinates = [params[:lat].to_f, params[:lng].to_f]
    elsif !params[:address].blank?
      coordinates = Geocoder.coordinates(params[:address])
    elsif coordinates.blank?
      coordinates = Geocoder.coordinates(DEFAULT_LOCATION)
    end
    
    types = params[:types].blank? ? get_types("Eat/Drink") : get_types(params[:types])    
    
    locations = Location.near(coordinates, 2, :order => :distance).where(:general_type => params[:types].blank? ? "Eat/Drink" : params[:types] ) 
      
    begin
      near_your_locations = HTTParty.get("https://maps.googleapis.com/maps/api/place/search/json?location=#{coordinates.join(',')}&types=#{types}&radius=#{RADIUS}&sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc")
    rescue
    end
      
      
    begin
      deals = RestClient.get "http://api.yipit.com/v1/deals/?key=zZnf9zms8Kxp6BPE&lat=#{coordinates[0]}&lon=#{coordinates[1]}"
      deals = Hash.from_xml(deals).to_json
      @deals = ActiveSupport::JSON.decode(deals)
    rescue
    end
      
    event_length = Event.near(coordinates, 2).length      
    @output = ""
    builder = Builder::XmlMarkup.new(:target=> @output, :indent=>1)
    builder.instruct!
    builder.Result {|r|
      r.BusinessList { |business_list|
        locations.each do |location|  
          unless location.reference.blank?
            business_list.Business {|business|            
              business.name(location.name)
              business.location(location.address)
              business.distance(location.distance)
              business.reference(location.reference)            
            }
          end
        end         
        near_your_locations['results'].each do |location|
          distance = Geocoder::Calculations.distance_between(coordinates, [location['geometry']['location']['lat'].to_f, location['geometry']['location']['lng'].to_f])
          business_list.Business {|business|
            business.name(location['name'])
            business.location(location['vicinity'])            
            business.distance(distance)
            business.reference(location['reference'])  
          }
        end                  
      }
      begin
        r.deal_size @deals['root']['response']['deals']['list_item'].size.to_s unless @deals.blank?                 
      rescue
      end
      r.event(event_length)
      r.lat(coordinates[0].to_s)
      r.lng(coordinates[1].to_s)
    }
      
    xml_res = builder.to_xml.gsub("<to_xml/>", "")
    render :xml => xml_res    
  end
  
  def deals
    coordinates = ""
    if !params[:lat].blank? && !params[:lng].blank?
      coordinates = [params[:lat].to_f, params[:lng].to_f]
    elsif !params[:address].blank?
      coordinates = Geocoder.coordinates(params[:address])
    elsif coordinates.blank?
      coordinates = Geocoder.coordinates(DEFAULT_LOCATION)
    end
    
    #get deals from yipit
    begin      
      deals = RestClient.get "http://api.yipit.com/v1/deals/?key=zZnf9zms8Kxp6BPE&lat=#{coordinates[0]}&lon=#{coordinates[1]}"
      deals = Hash.from_xml(deals).to_json
      @deals = ActiveSupport::JSON.decode(deals)
    rescue
		end 
    @output = ""
    builder = Builder::XmlMarkup.new(:target=> @output, :indent=>1)
   
    unless @deals.blank?  
      builder.Result {|r|
        r.Deals { |d|
          @deals['root']['response']['deals']['list_item'].each do |deal|
            d.Deal { |de|
              de.title(deal['yipit_title'])
              de.link(deal['yipit_url'])
            }            
          end
        }
      }
    end
    xml_res = builder.to_xml.gsub("<to_xml/>", "")
    
    render :xml => xml_res
  end
  
  def events
    coordinates = ""
    if !params[:lat].blank? && !params[:lng].blank?
      coordinates = [params[:lat].to_f, params[:lng].to_f]
    elsif !params[:address].blank?
      coordinates = Geocoder.coordinates(params[:address])
    elsif coordinates.blank?
      coordinates = Geocoder.coordinates(DEFAULT_LOCATION)
    end
    
    events = Event.near(coordinates, 2)
    @output = ""
    builder = Builder::XmlMarkup.new(:target=> @output, :indent=>1)
    builder.Result {|r|
      r.Events {|e| 
        events.each do |ev|
          e.Event { |eve|
            eve.name(ev.name)
            eve.address(ev.address)
            eve.description(ev.description)
          }
        end
      }
    }
    xml_res = builder.to_xml.gsub("<to_xml/>", "")
     
    render :xml => xml_res  
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
    
    advertise = get_logo(details, location)  
    advertise_url = advertise.blank? ? nil : advertise.photo.url(:medium)
    
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
      business.advertise_url advertise_url
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
  
  def remove_duplicate_locations
    @near_your_locations['results'].each_with_index do |place, ndx|
      @near_your_locations['results'][ndx] = nil if exclude_place?(place)
    end
    @near_your_locations['results'].compact!
  end
  
  def exclude_place?(place)
    # Exclude the place if the name is blank, 
    # or there is a place with the same name, address, or lat-lng in @locations
    return true if place['name'].blank?
    return false if @locations.nil?
    @locations.any? do |location|
      ( place['name'] == location.name ) ||
      ( place['vicinity'] && place['vicinity'].include?(location.address) ) ||
      ( place['geometry']['location']['lat'] == location.latitude && 
        place['geometry']['location']['lng'] == location.longitude )
    end
  end
  
  def get_logo(details, location)   
    adv = nil
    unless location.blank?      
      adv = Advertise.where("address_name like ? and business_name like ?", "%#{location.city}, #{location.state}%", "%#{location.name}%").first();      
      adv = Advertise.where("business_name like ? ", "%#{location.name}%").first() if adv.blank?
      adv = Advertise.where("address_name like ?", "%#{location.city}, #{location.state}%").first() if adv.blank?
      adv = Advertise.where("business_type = '#{location.types}'").first() if adv.blank?
    else
      loc = details['result']       
      if loc['vicinity'] != nil && loc['name'] != nil
        add, city = loc['vicinity'].split(",")          
        adv = Advertise.where("(address_name like ? or address_name like ? ) and business_name like ? ", "%#{city.strip}%", "%#{add.strip}%", "%#{loc['name']}%").first()
        adv = Advertise.where("business_name like ? ", "%#{loc['name']}%").first() if adv.blank?          
      end      
    end
    return adv
  end
  

  def types(general_type)
    results = ""
    if general_type.eql?("Eat/Drink")
      results = eat_drink
    elsif general_type.eql?("Relax/Care")
      results = relax_care
    elsif general_type.eql?("Shop/Find")
      results = shop_find
    end
    results
  end
    
  def get_general_type(type)    
    return "Eat/Drink" if eat_drink.include?(type)
    return "Relax/Care" if relax_care.include?(type)
    return "Shop/Find" if shop_find.include?(type)
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
  
  def get_types(types)
    results = ""
    if types.eql?("Eat/Drink")
      results = "bar%7Ccafe%7Crestaurant%7Cfood"
    elsif types.eql?("Relax/Care")
      results = "aquarium%7Cart_gallery%7Cbeauty_salon%7Cbowling_alley," +
        "casino%7Cgym%7Cmovie_theater%7Cmuseum%7Cnight_club%7Cpark%7Cspa"
    elsif types.eql?("Shop/Find")
      results = "clothing_store%7Cshoe_store%7Cconvenience_store"
    end
    results
  end
end
