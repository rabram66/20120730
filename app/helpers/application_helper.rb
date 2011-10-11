module ApplicationHelper
  
  def author_link(name, page_id)
    link_to name, "http://www.facebook.com/pages/#{name.gsub(" ", "-")}/#{page_id}",:target => "_blank"
  end
  
  def location
    #return @latlng unless @latlng.blank?
    return @details['result']['geometry']['location'] unless @details.blank?    
  end
  
  def business_name
    @details['result']['name']
  end
  
  def rating_info
    "Rating #{@details['result']['rating']} out of 5" unless @details['result']['rating'].blank?
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
  
  def last_post
    
  end
end
