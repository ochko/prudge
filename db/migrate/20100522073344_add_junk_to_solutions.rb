class AddJunkToSolutions < ActiveRecord::Migration
  def self.up
    add_column :solutions, :junk, :text, :default => nil
  end

  def self.down
    remove_column :solutions, :junk
  end
end
