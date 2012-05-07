# This utilitity reads a spreadsheet, then searches the website for each row for twitter and facebook information.
# Writing that information back to the spreadsheet and saving it.
require 'csv'

class Scraper
  
  attr_reader :filename, :book

  def initialize(args)
    @filename = args[:file]
  end
  
  def scrape
    puts "Scraping locations from #{filename}"

    File.open(filename,'r') do |file|

      @book = Spreadsheet.open file

      sheet = book.worksheet 0 # First worksheet
      count = 0

      CSV.open(File.join(Rails.root, 'New_Addresses_1_csv-types.csv'), 'wb') do |csv|

        sheet.each(1) do |row| # skip first row

          count += 1

          #     0            1         2       3          4         5     6       7      8          9         10      11           12         13     14
          # #(number) Keyword Search  Name Address-1 Address-2 Address-3 City  State Zip Code  Neighborhood  Phone  Website Category Found  Twitter Facebook 
          next if row[0].nil? || strip(row[7]).blank? # Skip empty rows and entries without a State 

          data = {:types => row[1], :name => row[2]}

          csv << data.values

          print '.'
          $stdout.flush

        end
      end
    end
    puts "\nDone"
  end

  private
  
  def strip(value)
    value && value.strip
  end
  
end