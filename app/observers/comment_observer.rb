class CommentObserver < ActiveRecord::Observer
  def after_create(comment)
    comment.topic.update_attribute(:commented_at, Time.now)
  end
end
