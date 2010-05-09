class AddInvalidationToSolutions < ActiveRecord::Migration
  def self.up
    add_column :solutions, :invalidated, :boolean, :default => false
  end

  def self.down
    remove_column :solutions, :invalidated, :default => false
  end
end
