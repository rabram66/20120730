# This utilitity reads a CSV, then searches the website for each row for twitter and facebook information.
# Writing that information to a new CSV and saving it.
require 'open-uri'
require 'nokogiri'
require 'csv'

class CsvScraper
  
  attr_reader :filename, :book

  def initialize(args={})
    @filename = args[:file] || File.join(Rails.root,'SF_Austin.csv')
  end
#
#  Restaurants,Potbelly's Sandwich Works,5304 N Clark St,Chicago,IL,60640,"Andersonville, Edgewater",NULL,http://www.potbelly.com/,Sandwiches
  
  def scrape
    puts "Scraping locations from #{filename}"

    CSV.open(File.join(Rails.root, 'NewAddresses_SF_Austin.csv'), 'wb') do |csv|

      csv << ['types','name','address','city','state','phone','twitter_name','facebook_page_id']

      count = 0

      CSV.foreach(filename, :headers => true) do |row|

        count += 1

        # 0,      1          2       3          4       5       6    7    
        # #,Keyword Search,Name,Address-1,Address-2,Address-3,City,State,Zip Code,Neighborhood,Phone,Website,Category Found

        next if row[0].nil? || strip(row[7]).blank? # Skip empty rows and entries without a State

        data = {:types => row['Keyword Search'], :name => row['Name'], :address => row['Address-1'], :city => row['City'], :state => row['State'], :phone => row['Phone'], :twitter_name => '',:facebook_page_id => ''}

        url = strip(row['Website'])
        
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
    puts "\nDone"
  end

  private
  
  def strip(value)
    value && value.strip
  end
  
end