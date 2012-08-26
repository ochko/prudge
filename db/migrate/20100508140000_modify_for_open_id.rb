class ModifyForOpenId < ActiveRecord::Migration
  def self.up
    add_column :users, :openid_identifier, :string
    add_column :users, :persistence_token, :string, :null => false
    add_column :users, :single_access_token, :string, :null => false
    add_column :users, :perishable_token, :string, :null => false
    add_column :users, :password_salt, :string, :default => nil, :null => true
    
    change_column :users, :login, :string, :default => nil, :null => true
    change_column :users, :crypted_password, :string, :default => nil, :null => true
    change_column :users, :email, :string, :null => false
    
    remove_column :users, :remember_token                         
    remove_column :users, :remember_token_expires_at              
    remove_column :users, :activation_code
    remove_column :users, :activated_at                           
    remove_column :users, :password_reset_code
    
    rename_column :users, :school_name, :school
    rename_column :users, :self_intro, :about
    
    add_index :users, :openid_identifier
  end

  def self.down
    remove_column :users, :openid_identifier
    remove_column :users, :persistence_token
    remove_column :users, :single_access_token
    remove_column :users, :perishable_token
    remove_column :users, :password_salt
    
    change_column :users, :login, :string, :null => true
    change_column :users, :crypted_password, :string, :null => true
    change_column :users, :email, :string, :null => true
    
    add_column :users, :remember_token, :string
    add_column :users, :remember_token_expires_at, :datetime              
    add_column :users, :activation_code, :string
    add_column :users, :activated_at, :datetime
    add_column :users, :password_reset_code, :string

    rename_column :users, :school, :school_name
    rename_column :users, :about, :self_intro
    
  end
end
