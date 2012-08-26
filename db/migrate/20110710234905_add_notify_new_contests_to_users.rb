class AddNotifyNewContestsToUsers < ActiveRecord::Migration
  def self.up
    add_column :users, :notify_new_contests, :boolean, :default => true
  end

  def self.down
    remove_column :users, :notify_new_contests
  end
end
