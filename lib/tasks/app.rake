require File.join(File.dirname(__FILE__), '/locations_spreadsheet')

namespace :app do
  namespace :import do
    desc "Import locations from a spreadsheet"
    task :locations, [:file] => :environment do |t, args|
      LocationsSpreadsheet.new(args).import
    end
  end

  desc "Reset locations"
  task :reset_locations => :environment do
    Location.find_each(&:save)
  end
end