class AddConferenceFlagToEvents < ActiveRecord::Migration
  def change
    add_column :events, :conference, :boolean, :default => false
  end
end
