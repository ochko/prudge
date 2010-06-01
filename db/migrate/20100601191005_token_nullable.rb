class TokenNullable < ActiveRecord::Migration
  def self.up
    change_column :users, :persistence_token, :string, :null => true
    change_column :users, :single_access_token, :string, :null => true
    change_column :users, :perishable_token, :string, :null => true
    change_column :users, :login, :string, :null => false
  end

  def self.down
    change_column :users, :persistence_token, :string, :null => false
    change_column :users, :single_access_token, :string, :null => false
    change_column :users, :perishable_token, :string, :null => false
    change_column :users, :login, :string, :null => true
  end
end
