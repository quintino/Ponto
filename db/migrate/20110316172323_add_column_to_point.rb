class AddColumnToPoint < ActiveRecord::Migration
  def self.up
    add_column :points, :user_id, :integer
  end

  def self.down
    remove_column :points, :user_id
  end
end
