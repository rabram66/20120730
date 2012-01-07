class AddFlyerToEvents < ActiveRecord::Migration
  def change
    add_column :events, :flyer, :string
  end
end
