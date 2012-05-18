require 'test_helper'

class LocationCategoryTest < ActiveSupport::TestCase
  context 'find_by_name' do
    should "return Play for fun" do
      assert_equal LocationCategory::Play, LocationCategory.find_by_name('fun')
    end
  end
end
