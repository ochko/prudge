class CreateHomeworks < ActiveRecord::Migration
  def self.up
    create_table :homeworks do |t|
    end
  end

  def self.down
    drop_table :homeworks
  end
end
