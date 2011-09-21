class Partay
   include HTTParty
  base_uri 'https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc1'
end

  #add to google API
   options = {
  :location => {
    :lat => :latitude, #'33.710933',
    :lng => :longitude #'-84.48017'
  }
    }  
    {
      :accuracy => '50',
  :name=>"Rays shooes",
  :types=> "shoe_store",
  :language=> "en-AU"
    }

Location.post('/public/pears.xml', options)