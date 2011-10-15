if Rails.env.production?
  BUCKET = 'nearbythis'
else
  BUCKET = 'nearbythisdevelopment'
end