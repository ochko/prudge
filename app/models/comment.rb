class Comment < ActiveRecord::Base
  belongs_to :user
  belongs_to :topic, :polymorphic => true
  validates_presence_of :text
end
