class CopyTopicsToPosts < ActiveRecord::Migration
  def up
    conn = ActiveRecord::Base.connection
    user_id = conn.select_value('select id from users where admin = 1 order by id limit 1')

    conn.select_all('SELECT * FROM topics').each do |topic|
      topic.symbolize_keys!

      execute("INSERT INTO posts "+
              "(author_id, category, title, body, created_at, updated_at) SELECT"+
              " #{user_id}, 'blog', topics.title, topics.description, topics.created_at, topics.created_at FROM topics WHERE topics.id = #{topic[:id]}")

      post_id = conn.select_value("SELECT id FROM posts WHERE category = 'blog' AND title = #{conn.quote topic[:title]} ORDER BY id DESC LIMIT 1")

      execute("UPDATE comments SET topic_type = #{conn.quote 'Post'}, topic_id = #{post_id} WHERE topic_type = 'Topic' AND topic_id = #{topic[:id]}")
    end
  end

  def down
    # not yet needed
  end
end
