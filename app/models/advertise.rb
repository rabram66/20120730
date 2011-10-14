class Advertise < ActiveRecord::Base
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "50x50>" },
    :storage => :s3,
    :bucket => 'nearbythis',
    :s3_credentials => {
      :access_key_id => ENV['S3_KEY'],
      :secret_access_key => ENV['S3_SECRET']
    }
end
