class CreateHolidays < ActiveRecord::Migration
  def self.up
    create_table :holidays do |t|
      t.integer :day
      t.integer :month
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :holidays
  end
end
