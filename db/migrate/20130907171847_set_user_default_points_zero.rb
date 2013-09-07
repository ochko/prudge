class SetUserDefaultPointsZero < ActiveRecord::Migration
  def up
    execute "UPDATE users SET points = 0 WHERE points IS NULL"
    change_column :users, :points, :float, :default => 0, :null => false
  end

  def down
    change_column :users, :points, :float, :default => 0, :null => true
  end
end
