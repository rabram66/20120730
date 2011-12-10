class AddCityStateToEvents < ActiveRecord::Migration
  def up
    change_table :events do |t|
      t.string :city
      t.string :state
    end
  end
  def down
    remove_column :events, :city
    remove_column :events, :state
  end
end
