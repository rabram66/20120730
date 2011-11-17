module MobileHelper

  def category_class_names(location)
    location.categories.map {|lc| lc.short_name.downcase}.join(' ')
  end

end
