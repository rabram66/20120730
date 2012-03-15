class AddProfileImageUrlAndDescriptionToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :description, :text
    add_column :locations, :profile_image_url, :string
  end
end
