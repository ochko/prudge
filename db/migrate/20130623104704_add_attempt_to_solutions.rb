class AddAttemptToSolutions < ActiveRecord::Migration
  def change
    add_column :solutions, :attempt_count, :integer, :default => 0, :null => false
    execute "UPDATE solutions SET attempt_count = 1"
  end
end
