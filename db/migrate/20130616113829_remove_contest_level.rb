class RemoveContestLevel < ActiveRecord::Migration
  def up
    remove_column :contests, :level
  end

  def down
    add_column :contests, :level, :integer, :default => 0
  end
end
