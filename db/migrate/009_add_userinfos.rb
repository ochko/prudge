class AddUserinfos < ActiveRecord::Migration
  def self.up
    add_column :users, :school_name, :string, :null => true
    add_column :users, :self_intro, :text, :null => true
  end

  def self.down
    remove_column :users, :school_name
    remove_column :users, :self_intro
  end
end
