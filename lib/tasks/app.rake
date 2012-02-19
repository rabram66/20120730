require File.join(File.dirname(__FILE__), '/locations_spreadsheet')

namespace :app do
  namespace :import do
    desc "Import locations from a spreadsheet"
    task :locations, [:file] => :environment do |t, args|
      LocationsSpreadsheet.new(args).import
    end
  end

  namespace :locations do

    desc "Resave"
    task :resave => :environment do
      Location.find_each(&:save)
    end

    desc "Verify using Google Places"
    task :verify => :environment do
    end

  end
  
end