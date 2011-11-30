class DropAdTrackings < ActiveRecord::Migration
  def up
    drop_table :ad_trackings
  end

  def down
    create_table :ad_trackings do |t|
      t.string :ip_address
      t.string :business_name
      t.integer :advertise_id

      t.timestamps
    end
  end
end
