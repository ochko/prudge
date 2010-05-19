class AddCachesToProblems < ActiveRecord::Migration
  def self.up
    add_column :problems, :tried_count, :integer, :default => 0
    add_column :problems, :solved_count, :integer, :default => 0
    Problem.reset_column_information
    Problem.collect_caches!
  end

  def self.down
    remove_column :problems, :tried_count
    remove_column :problems, :solved_count
  end
end
