require 'rubygems'
require 'httparty'

class Partay1
   include HTTParty
   base_uri 'https://maps.googleapis.com' 
   format :json
 end

  #add to google API
   options = {
       :location => {
    :lat => '33.71064',
    :lng => '-84.479605'
  }
   
    }
    {
   :accuracy => '50',
  :name=>"Rays NewshoeTree",
  :types=> "shoe_store",
  :language=> "en-AU"
    }

#Partay.post('/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc1', { :location => {:lat => '33.71064',:lng => '-84.479605'}} )
