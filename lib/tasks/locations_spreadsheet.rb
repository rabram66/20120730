class LocationsSpreadsheet
  
  attr_reader :filename, :book

  def initialize(args)
    @filename = args[:file]
  end
  
  def import
    puts "Importing locations from #{filename}"
    File.open(filename,'r') do |file|
      @book = Spreadsheet.open file
      sheet = book.worksheet 0 # First worksheet
      sheet.each(1) do |row| # skip first row
        # COMPANY_NAME, ADDRESS, CITY, STATE, ZIP, Category, Twitter_Name
        begin
          next unless row[0] # Skip empty rows
          Location.new(
            :name         => row[0].strip,
            :address      => row[1].strip,
            :city         => row[2].strip,
            :state        => row[3].strip,
            :types        => category_to_type(row[5]),
            :twitter_name => row[6].strip
          ).save!
          print '.'; $stdout.flush
        rescue
          puts "Error processing #{row.inspect}: #{$!}"
        end
      end
    end
    puts "\nDone"
  end

  private

  def category_to_type(category)
    case category.strip
      when /^store/i; "clothing_store"
      when "Relax"; "beauty_salon"
      when /^spas/i; "spa"
      when /^nightclub/i; "night_club" 
      else "restaurant"
    end
  end

end