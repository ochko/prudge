class AddMailedToUser < ActiveRecord::Migration
  def self.up
    add_column :users, :mailed, :boolean, :default => false
  end

  def self.down
    remove_column :users, :mailed
  end
end
