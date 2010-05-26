class SetDefaultPoint < ActiveRecord::Migration
  def self.up
    change_column :solutions, :point, :float, :default => 0.0
    Solution.update_all("point = 0", "point is NULL")
  end

  def self.down
    change_column :solutions, :point, :float
  end
end
