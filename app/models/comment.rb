class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic, :polymorphic => true, :counter_cache => true
  validates_presence_of :text

  paginates_per 15
end
