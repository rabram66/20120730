# This utilitity reads a spreadsheet, then searches the website for each row for twitter and facebook information.
# Writing that information back to the spreadsheet and saving it.
require 'open-uri'
require 'hpricot'

class SpreadsheetScraper
  
  attr_reader :filename, :book

  def initialize(args)
    @filename = args[:file]
  end
  
  def scrape
    puts "Scraping locations from #{filename}"
    File.open(filename,'r') do |file|
      @book = Spreadsheet.open file
      sheet = book.worksheet 0 # First worksheet
      sheet.each(1) do |row| # skip first row
        # #(number) Name  Address-1 Address-2 City  State Zip Code  Neighborhood  
        # Phone Website Category Found  Twitter Facebook
        begin
          next unless row[0] # Skip empty rows
          url = strip(row[9])
          next if url.blank?
          puts url
          doc = open(url) {|f| Hpricot(f)}
          links = doc.search("//a").map{|a| a['href']}

          tlink = links.detect {|href| href =~ /twitter\.com/}
          row[11] = tlink.split('/').last if tlink

          flink = links.detect {|href| href =~ /facebook\.com/}
          row[12] = flink if flink
        rescue
          puts "Error processing #{row}: #{$!}"
        end
      end
      book.write 'SampleData-new.xls'
    end
    puts "\nDone"
  end

  private
  
  def strip(value)
    value && value.strip
  end
  
end