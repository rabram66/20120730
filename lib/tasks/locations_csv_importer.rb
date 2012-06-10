require 'csv'

class LocationsCsvImporter
  
  def initialize(args)
    @filename = args[:file] || 'ny_addresses.csv'
  end
  
  def import
    filename = File.join(Rails.root, @filename)
    puts "Importing locations from #{filename}"
    # Category  Name  Street  City  State Zip Phone Twitter
    CSV.foreach(filename, :headers => true) do |row|
      data = map_csv_data(row.to_hash)
      begin
        Location.create data
      rescue
        puts $!
      end
      print '.';$stdout.flush
    end
  end

  private

  # attr_accessible :name, :address, :city, :state, :twitter, 
  #                 :phone, :latitude, :longitude, :reference, :email, 
  #                 :types, :twitter_name, :facebook_page_id, :user_id,
  #                 :verified, :verified_on, :verified_by, :favorites_count, :last_favorited_at,
  #                 :profile_image_url, :description, :active
  # 
  
  def map_csv_data(d)
    { 
      :types   => transform_type(d['Category']),
      :name    => d['Name'], 
      :address => d['Street'], 
      :city    => d['City'], 
      :state   => d['State'], 
      :phone   => d['Phone'],
      :twitter_name => transform_twitter_name(d['Twitter'])
    }
  end

  def transform_twitter_name(name)
    if name
      name.strip!
      (name == 'n/a' || name.blank?) ? nil : name
    else
      nil
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
