module PlacesHelper
  def description_for(location)
    unless location.description.blank?
      res = content_tag :span do
        truncate(location.description, :length => 80)
      end
      res + tag('br')
    end
  end
end  