class AddIndexToDeals < ActiveRecord::Migration
  def change
    add_index :deals, [:provider, :provider_id]
  end
end
