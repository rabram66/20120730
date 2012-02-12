class AddSlugToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :slug, :string, :unique => true
    add_index :locations, :slug, :unique => true 
  end
end
