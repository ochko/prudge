class CreateMemberships < ActiveRecord::Migration
  def self.up
    create_table :memberships do |t|
    end
  end

  def self.down
    drop_table :memberships
  end
end
