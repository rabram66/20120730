require 'csv'

# import country data from countries cvs file
#puts "importing adv data..."
#Advertise.delete_all
#CSV.foreach("#{Rails.root}/db/advertises.csv") do |row|
#  adv = Advertise.new(:id => row[0], :business_type => row[1], 
#    :photo_file_name => row[2], :photo_content_type => row[3], 
#    :photo_file_size => row[4], :photo_updated_at => row[5],
#    :created_at => row[6], :updated_at => row[7])
#  adv.save
#end

#puts "update general location....."
#eat_drink = ["bakery", "coke", "bar", "cafe", "food", "meal takeaway", "restaurant"]  
#  
#relax_care = ["amusement park", "aquarium", "art gallery", "beauty salon", "bowling alley",
#  "casino", "gym", "hair care", "health", "movie theater", "museum", "night club", "park", "spa", "zoo"]  
#  
#shop_find = ["atm", "bank", "bicycle store", "book store", "bus station", "clothing store", "convenience store" ,
#  "department store", "electronics store", "establishment", "florist", "gas station", "grocery", "supermarket",
#  "hardware store", "home goods store", "jewelry store", "library", "liquor store", "locksmith", "pet store",
#  "pharmacy", "shoe store", "shopping mall", "store"]
#locations = Location.all
#
#locations.each do |location|
#   if eat_drink.include?(location.types) 
#     location.general_type = "Eat/Drink"
#   elsif relax_care.include?(location.types)
#     location.general_type = "Relax/Care"
#   elsif shop_find.include?(location.types)
#     location.general_type = "Shop/Find"
#   end    
#  location.save
#end

puts "create roles..."
["User", "Promoter", "Admin"].each do |role_name|
  Role.create(:name => role_name)
end