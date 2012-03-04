module MobileHelper

  def category_class_names(location)
    location.categories.map {|lc| lc.short_name.downcase}.join(' ')
  end

  def path_for_mobile_detail(location)
    mobile_detail_path(:id => location.slug)
  end

end
