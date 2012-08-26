class RemoveHomework < ActiveRecord::Migration
  def self.up
    drop_table :homeworks
  end

  def self.down
    create_table "homeworks" do |t|
      t.integer "lesson_id",  :null => false
      t.integer "problem_id", :null => false
    end
  end
end
