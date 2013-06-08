class RemoveOutputsInResults < ActiveRecord::Migration
  def up
    remove_column :results, :record_output
    remove_column :results, :record_diff
  end

  def down
    add_column :results, :record_output, :text
    add_column :results, :record_diff  , :text
  end
end
