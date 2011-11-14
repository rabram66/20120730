require 'rubygems'
require 'rest-client'

class Partay
   

    end



puts RestClient.post 'https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc1', :location => { :lat => '33.8669710' , :lng => '133.8669710'}, :accuracy => '50', :name => 'Rays Test', :types => ['restraurant']
