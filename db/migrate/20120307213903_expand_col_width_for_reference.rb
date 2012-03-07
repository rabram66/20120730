class ExpandColWidthForReference < ActiveRecord::Migration

  def change
    change_column :place_mappings, :reference, :text
    change_column :place_mappings, :slug, :text
  end
end
