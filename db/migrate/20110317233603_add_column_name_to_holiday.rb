class AddColumnNameToHoliday < ActiveRecord::Migration
  def self.up
    add_column :holidays, :name, :string
  end

  def self.down
    remove_column :holidays, :name
  end
end
