class ChangeCategory < ActiveRecord::Migration
  def self.up
    add_column :contests, :level, :integer, :default => 0
    Contest.reset_column_information
    Contest.all.each do |contest|
      level = case contest.category
                when "challenger" : 1
                when "beginner" : 2
                when "intermediate" : 3
                when "advanced" : 4
                else 0
              end
      contest.update_attribute(:level, level)
    end
    remove_column :contests, :category
  end

  def self.down
    add_column :contests, :category, :string, :default => 'none'
    Contest.reset_column_information
    Contest.all.each do |contest|
      category = case contest.level
                 when 1: "challenger"
                 when 2: "beginner"
                 when 3: "intermediate"
                 when 4: "advanced"
                 else "none"
                 end
      contest.update_attribute(:category, category)
    end
    remove_column :contests, :level
  end

end
