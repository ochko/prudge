class AddDatesToProblems < ActiveRecord::Migration
  def self.up
    add_column :problems, :active_from, :datetime
    add_column :problems, :inactive_from, :datetime
    Problem.reset_column_information
    Problem.all.each do |problem|
      problem.update_attributes!(:active_from => problem.contest.start,
                                 :inactive_from => problem.contest.end) if problem.contest
    end
  end

  def self.down
    remove_column :problems, :active_from
    remove_column :problems, :inactive_from
  end
end
