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
          attrs = {
            :name         => strip(row[0]),
            :address      => strip(row[1]),
            :city         => strip(row[2]),
            :state        => strip(row[3]),
            :twitter_name => strip(row[6]),
            :types        => category_to_type(row[5])
          }
          attrs[:phone] = row[7].gsub(/[^0-9]/,'') unless row[7].blank?
          
          next if attrs[:twitter_name].blank?

          Location.new(attrs).save!

          print '.'; $stdout.flush
        rescue
          puts "Error processing #{row}: #{$!}"
        end
      end
    end
    puts "\nDone"
  end

  private
  
  def strip(value)
    value && value.strip
  end

  def category_to_type(category='')
    case category.strip
      when /^store/i; "clothing_store"
      when "Relax"; "beauty_salon"
      when /^spas/i; "spa"
      when /^nightclub/i; "night_club" 
      else "restaurant"
    end
  end

end