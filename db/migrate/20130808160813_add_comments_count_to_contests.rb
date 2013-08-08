class AddCommentsCountToContests < ActiveRecord::Migration
  def change
    add_column :contests, :comments_count, :integer, default: 0
  end
end
