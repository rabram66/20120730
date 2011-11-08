class AddReferenceToLocations < ActiveRecord::Migration
  def self.up
    #add_column :locations, :reference, :string
  end

  def self.down
    remove_column :locations, :reference
  end
end
