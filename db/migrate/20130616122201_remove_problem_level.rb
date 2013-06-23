class RemoveProblemLevel < ActiveRecord::Migration
  def up
    remove_column :problems, :level
  end

  def down
    add_column :problems, :level, :integer, :default => 1, :null => false
  end
end
