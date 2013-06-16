class RemoveContestPrivate < ActiveRecord::Migration
  def up
    remove_column :contests, :private
  end

  def down
    add_column :contests, :private, :boolean, :default => false
  end
end
