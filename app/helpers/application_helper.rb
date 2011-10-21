module ApplicationHelper
  
  def author_link(name, page_id)
    link_to name, "http://www.facebook.com/pages/#{name.gsub(" ", "-")}/#{page_id}",:target => "_blank"
  end
  
  def location
    #return @latlng unless @latlng.blank?
    unless @location.blank?
      return @location.latitude, @location.longitude
    else
      return @details['result']['geometry']['location']['lat'], @details['result']['geometry']['location']['lng'] unless @details.blank?    
    end
    
  end
  
  def business_name
    unless @location.blank?
      return @location.name
    else
      return @details['result']['name']
    end
  end
  
  def rating_info
    begin
    "Rating #{@details['result']['rating']} out of 5" unless @details['result']['rating'].blank?
    rescue
    end
  end
  
  def twitter_feed
    str = ""
    unless @last_tweet.blank?      
      str += @last_tweet.first["text"].gsub("\n", " ");
    end
    str
  end
  
  def facebook_feed
    str = ""
    unless @last_post.blank?
      str += @last_post.gsub("\n", " ")
    end
    str
  end
  
  def types(search_type)
    result = ""
    ['Eat/Drink', 'Relax/Care', 'Shop/Find'].each do |type|
      result += "<option #{"selected='selected'" if type.eql?(search_type)} value=#{type}>#{type}</option>"
    end
    result.html_safe
  end

end
