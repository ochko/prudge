class AddDiff < ActiveRecord::Migration
  def self.up
    add_column :results, :diff, :text
  end

  def self.down
    remove_column :results, :diff
  end
end
