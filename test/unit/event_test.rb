require 'test_helper'

class EventTest < ActiveSupport::TestCase

  setup do
    @event = events(:one)
  end

  test "should geocode when address changed" do
    @event.address = '2578 Binghamton Drive, Atlanta, GA'
    @event.expects(:geocode).once
    @event.save!
  end

  test "should not geocode unless address changed" do
    @event.description = 'Whoville Town Celebration'
    @event.expects(:geocode).never
    @event.save!
  end

end
