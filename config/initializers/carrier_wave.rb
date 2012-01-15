CarrierWave.configure do |config|
  config.root = Rails.root.join('tmp')
  config.cache_dir = 'carrierwave'
  
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => '09DQHTFR13R7DZE9HPG2', #'AKIAJXYKX3NYSWCCA5BQ',
    :aws_secret_access_key  => '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' #'MMmQeBAPL8vWedem3yi8EbKofNu1u46gQpUd2Jke' 
  }
  config.fog_directory  = 'bsiggelkow-nearbythis'
end
