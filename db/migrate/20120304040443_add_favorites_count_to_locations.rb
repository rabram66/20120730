class AddFavoritesCountToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :favorites_count, :integer, :default => 0
    add_column :locations, :last_favorited_at, :datetime
  end
end
