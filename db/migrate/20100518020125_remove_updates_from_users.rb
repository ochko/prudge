class RemoveUpdatesFromUsers < ActiveRecord::Migration
  def self.up
    remove_column :users, :updated_at
    remove_column :users, :last_request_at
  end

  def self.down
    add_column :users, :updated_at, :datetime
    add_column :users, :last_request_at, :datetime
  end
end
