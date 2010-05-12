class RemoveAbout < ActiveRecord::Migration
  def self.up
    remove_column :users, :about
  end

  def self.down
    add_column :users, :about, :string
  end
end
