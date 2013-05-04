class CopyLessonsToPosts < ActiveRecord::Migration
  def up
    conn = ActiveRecord::Base.connection

    conn.select_all('SELECT * FROM lessons').each do |lesson|
      lesson.symbolize_keys!

      execute("INSERT INTO posts "+
              "(author_id, category, title, body, created_at, updated_at) SELECT"+
              " lessons.author_id, 'blog', lessons.title, lessons.text, lessons.created_at, lessons.updated_at FROM lessons WHERE lessons.id = #{lesson[:id]}")

      post_id = conn.select_value("SELECT id FROM posts WHERE category = 'blog' AND title = #{conn.quote lesson[:title]} ORDER BY id DESC LIMIT 1")

      execute("UPDATE comments SET topic_type = #{conn.quote 'Post'}, topic_id = #{post_id} WHERE topic_type = 'Lesson' AND topic_id = #{lesson[:id]}")
    end
  end

  def down
  end
end
