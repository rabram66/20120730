class AddGeneralTypeToLocation < ActiveRecord::Migration
  def change
    add_column :locations, :general_type, :string
  end
end
