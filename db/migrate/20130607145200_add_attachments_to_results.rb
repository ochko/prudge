class AddAttachmentsToResults < ActiveRecord::Migration
  def change
    add_column :results, :output_file_name  , :text
    add_column :results, :output_file_size  , :integer
    add_column :results, :output_fingerprint, :text
    add_column :results, :output_updated_at , :timestamp
    add_column :results, :diff_file_name    , :text
    add_column :results, :diff_file_size    , :integer
    add_column :results, :diff_fingerprint  , :text
    add_column :results, :diff_updated_at   , :timestamp

    rename_column :results, :output, :record_output
    rename_column :results, :diff,   :record_diff
  end
end
