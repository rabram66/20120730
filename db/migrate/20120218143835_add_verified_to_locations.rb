class AddVerifiedToLocations < ActiveRecord::Migration
  def change
    add_column :locations, :verified, :boolean, :default => false
    add_column :locations, :verified_on, :date
    add_column :locations, :verified_by, :string
  end
end
