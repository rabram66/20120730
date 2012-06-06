class InlargeDealsUrlColumns < ActiveRecord::Migration
  def up
    change_column :deals, :url, :string, :limit => 1024
    change_column :deals, :mobile_url, :string, :limit => 1024
    change_column :deals, :thumbnail_url, :string, :limit => 1024
  end

  def down
    change_column :deals, :url, :string, :limit => 255
    change_column :deals, :mobile_url, :string, :limit => 255
    change_column :deals, :thumbnail_url, :string, :limit => 255
  end
end
