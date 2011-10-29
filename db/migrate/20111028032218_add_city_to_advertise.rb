class AddCityToAdvertise < ActiveRecord::Migration
  def change
    add_column :advertises, :city, :string    
    add_column :advertises, :state, :string    
    add_column :advertises, :business_name, :string
  end
end
