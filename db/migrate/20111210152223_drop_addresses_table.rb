class DropAddressesTable < ActiveRecord::Migration
  def up
    drop_table :addresses
  end

  def down
    create_table :addresses do |t|
      t.string :name
      t.timestamps
    end
  end
end
