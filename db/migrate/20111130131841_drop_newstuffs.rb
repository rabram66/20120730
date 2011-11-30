class DropNewstuffs < ActiveRecord::Migration
  def up
    drop_table :newstuffs
  end

  def down
    create_table "newstuffs" do |t|
      t.string   "mystuff"
      t.string   "yourstuff"
      t.datetime "created_at"
      t.datetime "updated_at"
    end
  end
end
