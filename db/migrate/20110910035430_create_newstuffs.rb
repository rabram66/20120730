class CreateNewstuffs < ActiveRecord::Migration
  def self.up
    create_table :newstuffs do |t|
      t.string :mystuff
      t.string :yourstuff

      t.timestamps
    end
  end

  def self.down
    drop_table :newstuffs
  end
end
