class CreateDealLocations < ActiveRecord::Migration
  def change
    create_table :deal_locations do |t|
      t.references :deal
      t.string     :address
      t.string     :city
      t.string     :state
      t.string     :phone_number
      t.float      :latitude
      t.float      :longitude
      t.timestamps
    end
  end
end
