class RemoveAverageFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :average
  end

  def self.down
    add_column :users, :average, :float, :default => 0.0
  end
end
