class RemoveCommentsCounts < ActiveRecord::Migration
  def up
    %w[contests problems solutions].each do |name|
      change_table name do |t|
        t.remove :comments_count
        t.remove :commented_at
      end
    end
  end

  def down
    %w[contests problems solutions].each do |name|
      change_table name do |t|
        t.integer :comments_count, :default => 0
        t.datetime :commented_at
      end
    end
  end
end
