# A task for de-duping locations based on the following algorithms:
#  1. Find all records that have the same first 8 characters in their name and the same address
#  2. Group this set by those same values
#  3. For each group score the records based on:
#     - twitter name: 100
#     - facebook id: 10
#     - the most recent created date: 5
#     - the shortest name: 4

class LocationsDeduper
  
  def run
    dup_sets = find_dups
    dup_sets.each do |dup_set|
      locations = Location.where("name like ? and address = ?", 
        "#{dup_set['name_match']}%", dup_set['address_match']
      )
      best = choose_best( locations )
      puts locations.inspect
      locations.each do |location|
        Location.destroy(location.id) unless location.id == best.id
      end
    end
  end
  
  private 
  
  def find_dups
    sql = <<-SQL
      select substring(n1.name from 1 for 8) as name_match, n1.address as address_match
      from locations n1 join locations n2 
      on substring(n1.name from 1 for 8) = substring(n2.name from 1 for 8) 
      and n1.address = n2.address 
      and n1.id != n2.id 
      group by name_match, address_match
    SQL
    Location.connection.select_all( sql )
  end

  def choose_best(locations)
    scores = calculate_scores(locations)
    scores.sort { |a,b| a[:score] <=> b[:score] }.last[:location]
  end
  
  def calculate_scores(locations)
    shortest = locations.sort { |a,b| a.name.length <=> b.name.length }.first.id
    most_recent = locations.sort { |a,b| a.created_at <=> b.created_at }.last.id
    locations.map do |location|
      score = 0
      score += 100 if location.twitter_name.present?
      score += 20  if location.facebook_page_id.present?
      score += 10  if location.general_type == 'Eat/Drink'
      score += 4   if location.profile_image_url.present?
      score += 1   if location.id == most_recent
      score += 3   if location.id == shortest
      {:score => score, :location => location}
    end
  end
  
end