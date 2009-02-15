class Topic < ActiveRecord::Base
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :include => [:user],
           :dependent => :destroy,
           :order => 'comments.id'

  validates_presence_of :title, :description

  acts_as_textiled :description

end
