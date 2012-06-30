class CreateInstructions < ActiveRecord::Migration
  def self.up
    create_table :instructions do |t|
      t.integer :teacher_id
      t.integer :course_id
    end
  end

  def self.down
    drop_table :instructions
  end
end
