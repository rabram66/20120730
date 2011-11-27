module ApplicationHelper
  
  def author_link(name, page_id)
    link_to name, "http://www.facebook.com/pages/#{name.gsub(" ", "-")}/#{page_id}",:target => "_blank"
  end
  
  def rating_info
    begin
      "Rating #{@details['result']['rating']} out of 5" unless @details['result']['rating'].blank?
    rescue
    end
  end
  
  def format_tweet_for_map(tweet)
    tweet.text.gsub("\n", " ").gsub(/"/, "")
  end

  def format_wall_post_for_map(wall_post)
    wall_post.text.gsub("\n", " ")
  end

end
