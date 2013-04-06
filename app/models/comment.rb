class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic, :polymorphic => true, :counter_cache => true
  validates_presence_of :text

  def self.per_page
    15
  end

  after_create do |comment|
    comment.topic.update_attribute(:commented_at, Time.now)
  end
end
