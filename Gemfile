source 'http://rubygems.org'

gem 'rails', '3.1.0.rc5'
gem 'rack', '1.3.3'

# Geocoder version that plays better with pagination
gem 'geocoder', :git => 'git://github.com/alexreisner/geocoder.git', :ref => '0e157f6794'

gem 'httparty'                     # calls external APIs
gem 'heroku'                       # manages deployment
gem 'rest-client', '~> 1.6.7'      # calls external APIs
gem "jquery-rails"                 # integrates jquery with rails
gem 'pg'                           # PostgreSQL db adapter
gem "devise"                       # authentication
gem "mobile-fu"                    # mobile detection
gem "faster_haversine", "~> 0.1.3" # Calculating distance between geocodes
gem 'stamp'                        # user-friendly date-time formatting
gem 'chronic'                      # user-friendly date-time parsing
gem 'hoptoad_notifier'             # exception notification
gem 'spreadsheet'                  # used for spreadsheet imports
gem 'taps'                         # enables heroku db:push
gem 'dalli'                        # memcached interface
gem 'rinku'                        # autolink tweet and facebook text
gem 'will_paginate', '~> 3.0'      # pagination in admin pages
gem 'cancan'                       # authorization
gem 'carrierwave'                  # file uploads
gem 'fog'                          # AWS/S3 upload storage
gem 'delayed_job_active_record'    # background job processor

group :development, :test do
  gem 'ansi'     # colorize turn output
end

group :test do
  gem 'turn'     # test unit reporter
  gem 'minitest' # undeclared dependency for turn
  gem 'shoulda' # better testing
  gem 'shoulda-matchers' # better testing
  gem 'mocha'   # stubs objects
  gem 'webmock' # stubs web requests
end

