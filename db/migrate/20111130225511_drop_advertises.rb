class DropAdvertises < ActiveRecord::Migration
  def up
    drop_table :advertises_locations
    drop_table :advertises
  end

  def down
    create_table "advertises" do |t|
      t.string   "business_type"
      t.string   "photo_file_name"
      t.string   "photo_content_type"
      t.integer  "photo_file_size"
      t.datetime "photo_updated_at"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.string   "address_name"
      t.string   "business_name"
    end

    create_table "advertises_locations", :id => false do |t|
      t.integer "advertise_id"
      t.integer "location_id"
    end
  end
end
