class RemoveSolutionsIsbest < ActiveRecord::Migration
  def self.up
    remove_column 'solutions', 'isbest'
  end

  def self.down
    add_column 'solutions', 'isbest', :boolean, :default => true, :null => false
  end
end
