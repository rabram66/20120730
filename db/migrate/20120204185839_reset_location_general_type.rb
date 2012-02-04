class ResetLocationGeneralType < ActiveRecord::Migration
  def up
    execute <<-SQL
      UPDATE locations
        SET general_type = 'Spa'
        WHERE general_type = 'Relax/Care'
        AND types IN ('spa','beauty_salon')
    SQL
    execute <<-SQL
      UPDATE locations
        SET general_type = 'Play'
        WHERE general_type = 'Relax/Care'
        AND types NOT IN ('spa','beauty_salon')
    SQL
  end

  def down
    execute <<-SQL
      UPDATE locations
        SET general_type = 'Relax/Care'
        WHERE general_type = 'Play'
        AND types NOT IN ('spa','beauty_salon')
    SQL
    execute <<-SQL
      UPDATE locations
        SET general_type = 'Relax/Care'
        WHERE general_type = 'Spa'
        AND types IN ('spa','beauty_salon')
    SQL
  end
end
