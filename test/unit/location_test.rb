require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  
  setup do
    @location = locations(:one)
  end
  
  test "should not geocode when non-geographic attributes are changed" do
    @location.email = 'foo@bar.com'
    @location.expects(:geocode).never
    @location.save!
  end
  
  ['city','state','address'].each do |attr|
    test "should geocode when '#{attr}' changed" do
      @location.send("#{attr}=", 'test')
      @location.expects(:geocode).once
      @location.save!
    end
  end
  
end
