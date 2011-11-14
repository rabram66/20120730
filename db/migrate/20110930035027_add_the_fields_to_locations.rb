class AddTheFieldsToLocations < ActiveRecord::Migration
  def self.up
    add_column :locations, :email, :string
    add_column :locations, :types, :string
    add_column :locations, :accuracy, :integer, :default => 50
    rename_column :locations, :twitter, :twitter_name
    add_column :locations, :facebook_page_id, :string    
  end

  def self.down
    remove_column :locations, :email
    remove_column :locations, :types
    remove_column :locations, :accuracy
    rename_column :locations, :twitter_name, :twitter
    remove_column :locations, :facebook_page_id    
  end
end
