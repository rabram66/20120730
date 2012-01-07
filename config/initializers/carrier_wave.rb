CarrierWave.configure do |config|
  config.fog_credentials = {
    :provider               => 'AWS',
    :aws_access_key_id      => '09DQHTFR13R7DZE9HPG2',
    :aws_secret_access_key  => '2R3uzh5EiX0PfNGDDZ7mBq/Qt1SSukV9NNDAbULG'
  }
  config.fog_directory  = 'bsiggelkow-nearbythis'
end
