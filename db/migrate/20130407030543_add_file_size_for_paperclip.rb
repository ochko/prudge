class AddFileSizeForPaperclip < ActiveRecord::Migration
  def self.up
    add_column :solutions, :source_file_size, :integer
  end

  def self.down
    remove_column :solutions, :source_file_size
  end
end
