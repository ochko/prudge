class AddCommentsCountCommentedAt < ActiveRecord::Migration
  def self.up
    add_column :topics,   :comments_count, :integer,  :default => 0
    add_column :topics,   :commented_at,   :datetime, :default => nil
    add_column :contests, :comments_count, :integer,  :default => 0
    add_column :contests, :commented_at,   :datetime, :default => nil
    add_column :problems, :comments_count, :integer,  :default => 0
    add_column :problems, :commented_at,   :datetime, :default => nil
    add_column :lessons,  :comments_count, :integer,  :default => 0
    add_column :lessons,  :commented_at,   :datetime, :default => nil
    add_column :solutions,  :comments_count, :integer,  :default => 0
    add_column :solutions,  :commented_at,   :datetime, :default => nil

    Topic.reset_column_information
    Contest.reset_column_information
    Problem.reset_column_information
    Lesson.reset_column_information
    Solution.reset_column_information
    Comment.delete_all("topic_type = 'Task'")
    Comment.find(:all, 
                 :select => "topic_type, topic_id, count(id) as count, max(created_at) as last_created", 
                 :group => "topic_type, topic_id").each do |comments|
      if comments.topic
        comments.topic.class.
          update_counters(comments.topic.id, :comments_count => comments.count.to_i)
        comments.topic.
          update_attribute(:commented_at, comments.last_created)
      else
        Comment.delete_all(["topic_type = ? AND topic_id = ?",
                           comments.topic_type, comments.topic_id])
      end
    end
  end

  def self.down
    remove_column :topics,   :comments_count
    remove_column :topics,   :commented_at  
    remove_column :contests, :comments_count
    remove_column :contests, :commented_at
    remove_column :problems, :comments_count
    remove_column :problems, :commented_at
    remove_column :lessons,  :comments_count
    remove_column :lessons,  :commented_at  
    remove_column :solutions,  :comments_count
    remove_column :solutions,  :commented_at  
  end
end
