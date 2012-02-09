module ApplicationHelper
  
  def author_link(name, page_id)
    link_to name, "http://www.facebook.com/pages/#{name.gsub(" ", "-")}/#{page_id}",:target => "_blank"
  end
  
  def rating_info(place)
    "Rating #{place.rating} out of 5" unless place.rating.blank?
  end
  
  def google_map_url(location)
    "http://maps.google.com/maps?q=#{location.coordinates.join(',')}"
  end

  def title_tag
    content_tag(:title, @title || 'Nearby restaurants, shops, salons - Nearbythis')
  end

end
