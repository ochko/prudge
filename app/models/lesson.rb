class Lesson < ActiveRecord::Base
  belongs_to :author, :class_name=>'User', :foreign_key => 'author_id'

  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy

  validates_presence_of     :title, :text
  scope :commented, :conditions => "comments_count > 0"

  paginates_per 10

  def name
    title
  end
end
