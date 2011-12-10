module ApplicationHelper
  
  def author_link(name, page_id)
    link_to name, "http://www.facebook.com/pages/#{name.gsub(" ", "-")}/#{page_id}",:target => "_blank"
  end
  
  def rating_info(place)
    "Rating #{place.rating} out of 5" unless place.rating.blank?
  end
  
  def format_tweet_for_map(tweet)
    tweet.text.gsub("\n", " ").gsub(/"/, "")
  end

  def format_wall_post_for_map(wall_post)
    wall_post.text.gsub("\n", " ")
  end

  def google_map_url(location)
    "http://maps.google.com/maps?q=#{location.coordinates.join(',')}"
  end

end
