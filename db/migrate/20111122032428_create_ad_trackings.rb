class CreateAdTrackings < ActiveRecord::Migration
  def change
    create_table :ad_trackings do |t|
      t.string :ip_address
      t.string :business_name
      t.integer :advertise_id

      t.timestamps
    end
  end
end
