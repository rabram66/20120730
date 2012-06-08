class AddIndexOnDealIdDealLocations < ActiveRecord::Migration
  def change
    add_index :deal_locations, :deal_id
  end
end
