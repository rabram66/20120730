class Advertise < ActiveRecord::Base
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "50x50>" }
end
