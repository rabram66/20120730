class PlaceMapping < ActiveRecord::Base
  
  SLUG_PREFIX = 'pg'
  
  extend FriendlyId
  friendly_id :slugged_id, :use => :history

  def prefixed_name_and_city
    "#{SLUG_PREFIX} #{name} #{city}"[0..250]
  end
  
end
