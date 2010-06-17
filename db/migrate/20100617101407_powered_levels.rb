class PoweredLevels < ActiveRecord::Migration
  POWERS = { 3 => 4, 4 => 8}
  REVPOW = { 4 => 3, 8 => 4}
  def self.up
    Problem.all.each do |problem|
      if problem.level > 2
        problem.update_attribute(:level, POWERS[problem.level]) 
        problem.solutions.each do |solution|
          solution.update_attribute(:point, solution.percent * problem.level)
        end
      end
    end
    User.resum_points!
  end

  def self.down
    Problem.all.each do |problem|
      if problem.level > 2
        problem.update_attribute(:level, REVPOW[problem.level]) 
        problem.solutions.each do |solution|
          solution.update_attribute(:point, solution.percent * problem.level)
        end
      end
    end
    User.resum_points!
  end
end
