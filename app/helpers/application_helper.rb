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

  def url_for_location_details(location, options={})
    controller_type = ApplicationController === self ? self.controller_name : controller.controller_name
    if controller_type == 'mobile'
      options.merge!({
        :action => 'detail',
        :id => location.slug
      })
    else
      options.merge!({
        :action => 'details',
        :address => location.full_address,  
        :bizname => location.name, 
        :type => location.types,
        :reference => location.slug
      })
    end
    url_for options
  end

  def short_url_for_location_details(location)
    UrlShortener.new.shorten(url_for_location_details(location, :only_path => false))
  end

  def profile_image_url(location)
    location.profile_image_url || location.category_image_url || "mobile/logo-trans.png"
  end

end
