class DeltaIndexes < ActiveRecord::Migration
  def self.up
    add_column :problems, :delta, :boolean, :default => true, :null => false
    add_column :lessons, :delta, :boolean, :default => true, :null => false
    add_column :contests, :delta, :boolean, :default => true, :null => false
    add_column :topics, :delta, :boolean, :default => true, :null => false
    add_column :pages, :delta, :boolean, :default => true, :null => false
  end

  def self.down
    remove_column :problems, :delta
    remove_column :lessons, :delta
    remove_column :contests, :delta
    remove_column :topics, :delta
    remove_column :pages, :delta
  end
end
