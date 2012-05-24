require 'test_helper'

class LocationTest < ActiveSupport::TestCase
  
  setup do
    @location = locations(:one)
  end

  context 'relationships' do
    should belong_to(:user)
  end

  context 'finders' do
    should 'only find active locations by default' do
      assert_equal Location.where(:active => true).to_sql, Location.scoped.to_sql
    end
    should 'allow finding of inactive locations' do
      assert_not_equal Location.unscoped.to_sql, Location.scoped.to_sql
    end
  end
  
  context 'validations' do
    should validate_presence_of(:name)
    should validate_presence_of(:address)
    should validate_presence_of(:city)
    should validate_presence_of(:state)
    should validate_uniqueness_of(:name).scoped_to(:address)
  end
  
  context 'geocoding' do
    should "not geocode when non-geographic attributes are changed" do
      @location.email = 'foo@bar.com'
      @location.expects(:geocode).never
      Place.expects(:delete).never
      Place.expects(:add).never
      assert @location.save!
    end
  
    ['city','state','address'].each do |attr|
      should "geocode when '#{attr}' changed" do
        @location.send("#{attr}=", 'test')
        @location.expects(:geocode).once
        Place.expects(:delete).once
        Place.expects(:add).once
        @location.save!
      end
    end
  end

  context "google places reference" do
    should "be deleted when location destroyed" do
      Place.expects(:delete).once
      @location.destroy
    end
  end
  
end
