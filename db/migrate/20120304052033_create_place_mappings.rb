class CreatePlaceMappings < ActiveRecord::Migration
  def change
    create_table :place_mappings do |t|
      t.string :name
      t.string :city
      t.string :reference
      t.string :slug
      t.integer :favorites_count, :default => 0
      t.datetime :last_favorited_at
      t.timestamps
    end
    add_index :place_mappings, :slug, unique: true
  end
end
