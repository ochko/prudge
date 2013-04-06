class RemoveSolutionSourceTypeAndSize < ActiveRecord::Migration
  def self.up
    remove_column 'solutions', 'source_content_type'
    remove_column 'solutions', 'source_file_size'
    rename_column 'solutions', 'uploaded_at', 'source_updated_at'
  end

  def self.down
    add_column 'solutions', 'source_content_type', :string
    add_column 'solutions', 'source_file_size', :string
    rename_column 'solutions', 'source_updated_at', 'uploaded_at'
  end
end
