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
  
  context 'defaults' do
    should 'rank default to 1' do
      e = Event.new
      assert_equal 1, e.rank
    end
    should 'thumbnail_url should default to event icon' do
      e = Event.new
      assert_equal '/images/event_icon.jpg', e.thumbnail_url
    end
    should 'allow non-defaults on initialization' do
      e = Event.new(:rank => 10, :thumbnail_url => "http://foo.com/bar.gif")
      assert_equal 10, e.rank
      assert_equal "http://foo.com/bar.gif", e.thumbnail_url
    end
  end
  
end
