class CreateLocationsAdvertiseJoinTable < ActiveRecord::Migration
   def up
    create_table :advertises_locations, :id => false do |t|      
      t.integer :advertise_id  
      t.integer :location_id
    end
  end

  def down
    drop_table :advertises_locations
  end
end
