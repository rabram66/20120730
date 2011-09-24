require 'rubygems'
require 'httparty'

class Partay
   include HTTParty
   headers 'Content-Length' => '0' 
   base_uri 'https://maps.googleapis.com' 
    end

  #add to google API
  options = {
      :location => {
    :lat => '33.71064',
   :lng => '-84.479605'
      },
   :accuracy => 50,
  :name=>"Rays NewshoeTree",
  :types=> "[shoe_store]",
  :language=> "en-AU"
       }

puts Partay.post('/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc1', options )
