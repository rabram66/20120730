class AddPlacesIdToPlaceMappings < ActiveRecord::Migration
  def change
    add_column :place_mappings, :places_id, :string
    add_index :place_mappings, :places_id
  end
end
