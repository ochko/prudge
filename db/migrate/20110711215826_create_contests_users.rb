class CreateContestsUsers < ActiveRecord::Migration
  def self.up
    create_table :contests_users, :id => false do |t|
      t.integer :user_id
      t.integer :contest_id
    end

    add_index :contests_users, [:contest_id, :user_id], :unique => true
  end

  def self.down
    drop_table :contests_users
  end
end
