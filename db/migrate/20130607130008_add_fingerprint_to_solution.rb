class AddFingerprintToSolution < ActiveRecord::Migration
  def change
    add_column :solutions, :source_fingerprint, :text
    puts '>> recommended to run `rake prudge:reprocess:solutions`'
  end
end
