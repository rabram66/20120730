class AddSourceToEvents < ActiveRecord::Migration
  def change
    add_column :events, :source, :string
    add_column :events, :source_id, :string
    add_column :events, :rank, :integer
    add_column :events, :url, :string
    add_column :events, :thumbnail_url, :string
  end
end
