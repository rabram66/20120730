require 'test_helper'

class EventTest < ActiveSupport::TestCase

  setup do
    @event = events(:anonymous)
  end

  context 'geocoding' do
    should "happen when address changed" do
      @event.address = '2578 Binghamton Drive, Atlanta, GA'
      @event.expects(:geocode).once
      @event.save!
    end
    should "not happen when description changed" do
      @event.description = 'Whoville Town Celebration'
      @event.expects(:geocode).never
      @event.save!
    end
  end
  
  context 'full address' do
    should "be parsed into address, city, and state" do
      @event.full_address = "123 Herodian Way, Suite 104, Smyrna, GA"
      assert_equal "123 Herodian Way, Suite 104", @event.address
      assert_equal "Smyrna", @event.city
      assert_equal "GA", @event.state
      assert_equal "123 Herodian Way, Suite 104, Smyrna, GA", @event.full_address
    end
  end
  
end
