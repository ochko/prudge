class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
    end
  end

  def self.down
    drop_table :groups
  end
end
