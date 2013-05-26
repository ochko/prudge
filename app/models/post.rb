class Post < ActiveRecord::Base
  attr_accessible :body, :category, :title

  belongs_to :author, :class_name => "User"

  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy

  validates_presence_of :title, :body, :author

  paginates_per 10

  def name
    title
  end

  def text
    body
  end
end
