class AddSolvedInToSolutions < ActiveRecord::Migration
  def self.up
    add_column :solutions, :solved_in, :integer, :default => nil

    Solution.reset_column_information
    Problem.find(:all, :conditions => "contest_id is not null").each do |problem|
      problem.solutions.correct.update_all("solved_in = time")
    end
  end

  def self.down
    remove_column :solutions, :solved_in
  end
end
