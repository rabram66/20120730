class AddCityToAdvertise < ActiveRecord::Migration
  def change
    add_column :advertises, :address_name , :string    
    add_column :advertises, :business_name, :string
  end
end
