
require 'rubygems'
require 'httparty'

class Partay
   include HTTParty
   base_uri 'https://maps.googleapis.com' 
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

 headers = { "Content-type" => "application/x-www-form-urlencoded; charset=UTF-8", "Content-Length" => "0" }
#Partay.post('/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc1', { :location => {:lat => '33.71064',:lng => '-84.479605'}} )
