class RemoveRoles < ActiveRecord::Migration
  def self.up
    drop_table :roles
    drop_table :role_users
  end

  def self.down
    create_table "role_users", :force => true do |t|
      t.integer "role_id", :null => false
      t.integer "user_id", :null => false
    end

    create_table "roles", :force => true do |t|
      t.string "title", :null => false
    end

  end
end
