class AddPrivateToContests < ActiveRecord::Migration
  def self.up
    add_column :contests, :private, :boolean, :default => false
  end

  def self.down
    remove_column :contests, :private
  end
end
