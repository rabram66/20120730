module ApplicationHelper
  
  def author_link(name, page_id)
    link_to name, "http://www.facebook.com/pages/#{name.gsub(" ", "-")}/#{page_id}",:target => "_blank"
  end
  
  def location
    @details['result']['geometry']['location'] unless @details.nil?
  end
  
  def business_name
    @details['result']['name']
  end
  
  def rating_info
    "Rating #{@details['result']['rating']} out of 5" unless @details['result']['rating']
  end
  
  def last_tweet
    
  end
  
  def last_post
    
  end
end
