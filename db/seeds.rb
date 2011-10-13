require 'csv'

# import country data from countries cvs file
puts "importing adv data..."
Advertise.delete_all
CSV.foreach("#{Rails.root}/db/advertises.csv") do |row|
  adv = Advertise.new(:id => row[0], :business_type => row[1], 
    :photo_file_name => row[2], :photo_content_type => row[3], 
    :photo_file_size => row[4], :photo_updated_at => row[5],
    :created_at => row[6], :updated_at => row[7])
  adv.save
end
