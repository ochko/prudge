class AddTestsCount < ActiveRecord::Migration
  def self.up
    add_column :problems, :tests_count, :integer, :default => 0
    Problem.reset_column_information
    ProblemTest.find(:all, :select => 'problem_id as id, count(id) as count',
                     :group => 'problem_id').each do |test|
      Problem.update_counters(test.id, :tests_count => test.count.to_i)
    end
    
  end

  def self.down
    remove_column :problems, :tests_count
  end
end
