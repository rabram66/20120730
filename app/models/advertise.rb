class Advertise < ActiveRecord::Base
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "50x50>" },
    :storage => :s3,
    :bucket => BUCKET,
    :s3_credentials => {
      :access_key_id => "AKIAJTNES3VB7PXOEBZQ",
      :secret_access_key => "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"
    }
end
