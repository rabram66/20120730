class CreateDeals < ActiveRecord::Migration
  def change
    create_table :deals do |t|
      t.string   :source
      t.string   :source_id
      t.string   :title
      t.text     :description
      t.string   :name
      t.string   :url
      t.string   :mobile_url
      t.string   :thumbnail_url
      t.datetime :start_date
      t.datetime :end_date
      t.timestamps
    end
  end
end
