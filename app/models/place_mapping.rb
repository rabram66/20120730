class PlaceMapping < ActiveRecord::Base
  
  SLUG_PREFIX = 'pg'
  
  extend FriendlyId
  friendly_id :prefixed_name_and_city, :use => :history

  def prefixed_name_and_city
    "#{SLUG_PREFIX} #{name} #{city}"
  end
  
end
