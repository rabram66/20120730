class AddBizInfoToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :city, :string
    add_column :locations, :state, :string
    add_column :locations, :twitter, :string
    add_column :locations, :phone, :string
  end

  def self.down
    
  end
end
