require_relative 'locations_spreadsheet'
require_relative 'locations_verifier'
require_relative 'locations_updater'

namespace :app do
  namespace :import do
    desc "Import locations from a spreadsheet"
    task :locations, [:file] => :environment do |t, args|
      LocationsSpreadsheet.new(args).import
    end

    desc "Import locations from a CSV"
    task :locations_csv, [:file] => :environment do |t, args|
      LocationsCsvImporter.new(args).import
    end
    
    namespace :deals do

      desc "Import deals from Half Off Depot" 
      task :half_off_depot => :environment do
        Deals::HalfOffDepotImporter.new.import
      end

      desc "Import deals from Scoutmob" 
      task :scoutmob => :environment do
        Deals::ScoutmobImporter.new.import
      end

    end

  end

  namespace :locations do

    desc "Resave"
    task :resave => :environment do
      Location.find_each(&:save)
    end

    desc "Verify using Google Places"
    task :verify => :environment do
      LocationsVerifier.new.run
    end

    desc "Set locations profile image from cache"
    task :update_profiles => :environment do |t,args|
      LocationsUpdater.new(args).run
    end

    desc "Delete duplicate locations based on matching name, address, and phone"
    task :dedupe => :environment do |t,args|
      LocationsDeduper.new.run
    end

    desc "Geocode locations"
    task :geocode => :environment do |t,args|
      LocationsGeocoder.new.run
    end

  end

end