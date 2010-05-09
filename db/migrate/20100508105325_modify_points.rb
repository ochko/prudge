class ModifyPoints < ActiveRecord::Migration
  def self.up
    rename_column :problems, :point, :level
    add_column :solutions, :point, :float

    Problem.reset_column_information
    Solution.reset_column_information
    Problem.all.each do |problem|
      problem.level = if problem.level < 5 then
                        1
                      elsif problem.level > 15 then
                        3
                      else
                        2
                      end
      problem.save!
    end
    Solution.all.each do |solution|
      solution.point = solution.percent * solution.problem.level
      solution.send(:update_without_callbacks)
    end
  end

  def self.down
    rename_column :problems, :level, :point
    remove_column :solutions, :point
  end
end
