class AddReferenceColumn < ActiveRecord::Migration
  def up
    add_column :locations, :reference, :string
  end

  def down
    remove_column :locations, :reference
  end
end
