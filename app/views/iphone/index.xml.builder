xml.instruct!
xml.Result do |r|
  r.BusinessList do |business_list|
    @locations.each do |location|
      business_list.Business do |business|
        business.name      location.name
        business.location  location.address
        business.distance  location.distance
        business.reference location.reference
      end
    end
    @places.each do |place|
      business_list.Business do |business|
        business.name      place.name
        business.location  place.vicinity
        business.distance  place.distance_from(@coordinates)
        business.reference place.reference
      end
    end
  end
  r.deal_size @deals.length
  r.event @events.length
  r.lat @coordinates[0].to_s
  r.lng @coordinates[1].to_s
end
