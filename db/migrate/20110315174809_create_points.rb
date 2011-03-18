class CreatePoints < ActiveRecord::Migration
  def self.up
    create_table :points do |t|
      t.date :date_record
      t.time :morning_enter
      t.time :morning_exit
      t.time :afternoon_enter
      t.time :afternoon_exit
      t.time :overnight_enter
      t.time :overnight_exit
      t.integer :next_time

      t.timestamps
    end
  end

  def self.down
    drop_table :points
  end
end
