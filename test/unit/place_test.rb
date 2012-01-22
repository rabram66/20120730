require 'test_helper'

class PlaceTest < ActiveSupport::TestCase
  
  context 'find by reference' do

    context 'with invalid reference' do
      should "return nil" do
        body = %Q(
          {
             "html_attributions" : [],
             "status" : "INVALID_REQUEST"
          }
        )
        stub_request(:get, "https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc&reference=123&sensor=true").
                  to_return(:status => 200, :body => body, :headers => {})
        assert_raise Places::Api::NotFound do
          Place.find_by_reference '123'
        end
      end
    end
    
    context 'with valid reference' do
      setup do
        @ref="CmRdAAAABeOPmTRxAzY8qBPaZLGBCwjyH6vhBj-6wJF4D1CnbXLv7OGlfIp98RWt9RGcGrdNIp-HQwSR0HyPBygiUOa9BNSp7-VDrCavX7E-lO8if38sVvM_-jSrCTgQ39J5UccTEhDtQjar3E-UAtWprJVIwtrBGhQlRY2YTVlP5B8Y2YkEOyObsO00og"
        body = <<END_JSON
{
   "html_attributions" : [],
   "result" : {
      "geometry" : {
         "location" : {
            "lat" : 33.9283420,
            "lng" : -84.28184890
         }
      },
      "icon" : "http://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png",
      "id" : "667759c8c2bdfead1372c4ad6f805122cc44ed72",
      "name" : "Bangles R Us",
      "reference" : "CmRdAAAAnB_Ev9w1IBIQe_Fy_B7bd3SS4mDTHwxuIknyDGGTLOjMjotBsje4JeyHMYb3lr98PaKYAt1z9rPgFfUhxd-5iF5Xx99JK-1g5hNe_vcFAB7BWRrZ0bYtfTl0Jqj16UI9EhBh96Ksr4YawmsRNGmtkS4NGhQosTVPNMvssxNUbma9M4ZyyboRHg",
      "types" : [ "restaurant", "food", "establishment" ]
   },
   "status" : "OK"
}
END_JSON
        stub_request(:get, "https://maps.googleapis.com/maps/api/place/details/json?key=AIzaSyA1mwwvv3NAL_N7gNRf_0uqK2pfiXEqkZc&reference=#{@ref}&sensor=true").
          to_return(:status => 200, :body => body, :headers => {})
        @place = Place.find_by_reference @ref
      end

      should 'return a Place object for known reference' do
        assert_not_nil @place
      end

      should 'set attributes for the Place object' do
        assert_equal "Bangles R Us", @place.name
      end
    end
  end
  
end
