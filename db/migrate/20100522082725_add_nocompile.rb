class AddNocompile < ActiveRecord::Migration
  def self.up
    add_column :solutions, :nocompile, :boolean, :default => false
  end

  def self.down
    remove_column :solutions, :nocompile
  end
end
