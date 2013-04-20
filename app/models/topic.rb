class Topic < ActiveRecord::Base
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :include => [:user],
           :dependent => :destroy,
           :order => 'created_at DESC'

  validates_presence_of :title, :description

  scope :commented, :conditions => "TRUE"

  paginates_per 20
  
  def name
    title
  end

  def text
    description
  end
end
