require 'test_helper'

class DealTest < ActiveSupport::TestCase
  should have_many :deal_locations
  [:source, :source_id, :title, :description, :name, :start_date, :end_date,
   :url, :mobile_url, :thumbnail_url].each do |attribute|
    should allow_mass_assignment_of attribute
  end
end
