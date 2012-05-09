# This utilitity reads a spreadsheet, then searches the website for each row for twitter and facebook information.
# Writing that information back to the spreadsheet and saving it.
require 'open-uri'
require 'nokogiri'
require 'csv'

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
      count = 0

      CSV.open(File.join(Rails.root, 'NewAddresses_3.csv'), 'wb') do |csv|

        csv << ['types','name','address','city','state','phone','twitter_name','facebook_page_id']

        sheet.each(1) do |row| # skip first row

          count += 1

          #     0            1         2       3          4         5     6       7      8          9         10      11           12         13     14
          # #(number) Keyword Search  Name Address-1 Address-2 Address-3 City  State Zip Code  Neighborhood  Phone  Website Category Found  Twitter Facebook 
          next if row[0].nil? || strip(row[7]).blank? # Skip empty rows and entries without a State 

          data = {:types => row[1], :name => row[2], :address => row[3], :city => row[6], :state => row[7], :phone => row[10],:twitter_name => '',:facebook_page_id => ''}
          url = strip(row[11])

          unless url.blank?
            begin
              doc = Nokogiri::HTML(open(url))
              links = doc.search("//a").map{|a| a['href']}

              tlink = links.detect {|href| href =~ /twitter\.com/}
              data[:twitter_name] = tlink.split('/').last.gsub('#','') if tlink

              flink = links.detect {|href| href =~ /facebook\.com/}
              if flink
                case flink
                when %r{facebook.com/(\w+)$}
                  data[:facebook_page_id] = $1
                when %r{facebook.com/pages/[^0-9]*(\d+)($|\?)}
                  data[:facebook_page_id] = $1
                end
              end
            rescue
              puts "Error processing #{row}: #{$!}"
            end
          end

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