class AddRolesMaskToUsers < ActiveRecord::Migration
  def up
    add_column :users, :roles_mask, :integer, :default => 1 # guest
    remove_column :users, :role
  end
  def down
    remove_column :users, :roles_mask
    add_column :users, :role, :string
  end
end
