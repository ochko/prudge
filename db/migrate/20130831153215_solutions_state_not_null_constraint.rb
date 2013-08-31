class SolutionsStateNotNullConstraint < ActiveRecord::Migration
  def up
    change_column :solutions, :state, :text, :null => false, :default => 'updated'
  end

  def down
    change_column :solutions, :state, :text, :null => true, :default => nil
  end
end
