class PlaceMapping < ActiveRecord::Base
  
  SLUG_PREFIX = 'pg'
  
  extend FriendlyId
  friendly_id :slugged_id, :use => :history

  def slugged_id
    "#{SLUG_PREFIX} #{name} #{city}"
  end
  
end
