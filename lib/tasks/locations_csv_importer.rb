require 'csv'

class LocationsCsvImporter
  
  def initialize(args)
    @filename = args[:file] || 'NewAddresses_6.csv'
  end
  
  def import
    filename = File.join(Rails.root, @filename)
    puts "Importing locations from #{filename}"
    CSV.foreach(filename, :headers => true) do |row|
      data = row.to_hash
      data['types'] = transform_type(data['types'])
      begin
        Location.create data
      rescue
        puts $!
      end
      print '.';$stdout.flush
    end
  end

  def transform_type(val)
    case val.downcase
      when /arts/; 'art_gallery'
      when /restaurant/; 'restaurant'
      when /nightlife/; 'bar'
      when /beautysvc/; 'spa'
      when /shopping/; 'clothing_store'
      when /food/; 'food'
      else 'restaurant'
    end
  end

end
