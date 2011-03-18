class AddColumnToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :daily_hour, :time
  end

  def self.down
    remove_column :users, :daily_hour
  end
end
