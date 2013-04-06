class AddAttachmentsInputOutputToProblemTest < ActiveRecord::Migration
  def self.up
    add_column :problem_tests, :input_file_name, :string
    add_column :problem_tests, :output_file_name, :string
  end

  def self.down
    remove_column :problem_tests, :input_file_name
    remove_column :problem_tests, :output_file_name
  end
end
