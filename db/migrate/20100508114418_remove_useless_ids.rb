class RemoveUselessIds < ActiveRecord::Migration
  def self.up
    remove_column :contests, :type_id
    remove_column :contests, :prize_id
    remove_column :contests, :sponsor_id
    remove_column :problems, :problem_type_id
    
  end

  def self.down
    add_column :contests, :type_id, :integer
    add_column :contests, :prize_id, :integer
    add_column :contests, :sponsor_id, :integer
    add_column :problems, :problem_type_id, :integer
  end
end
