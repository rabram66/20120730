require 'test_helper'

class DealTest < ActiveSupport::TestCase
  should have_many :deal_locations
  [:source, :source_id, :title, :description, :name, :start_date, :end_date,
   :url, :mobile_url, :thumbnail_url].each do |attribute|
    should allow_mass_assignment_of attribute
  end
  
  context 'find' do
    should 'near given coordinates' do
      coords = [33.928342, -84.2818489] # 2578 Binghamton Drive, Atlanta, GA
      near = Deal.near(coords,2)
      assert !near.empty?
    end
  end  
end
