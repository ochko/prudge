class CopyPagesIntoPosts < ActiveRecord::Migration
  def up
    execute("INSERT INTO posts "+
            "(author_id, category, title, body, created_at, updated_at) SELECT"+
            " user_id, category, title, content, created_at, created_at FROM pages")

    execute("UPDATE posts SET category = 'help' WHERE category = 'rule'")
    execute("UPDATE posts SET category = 'blog' WHERE category = 'news'")
  end

  def down
    # not needed yet
  end
end
