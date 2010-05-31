class Lesson < ActiveRecord::Base
  belongs_to :author, :class_name=>'User', :foreign_key => 'author_id'

  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy

  validates_presence_of     :title, :text
  named_scope :commented, :conditions => "comments_count > 0"

  def self.per_page
    10 
  end

  def name
    title
  end

  def owned_by?(user)
    user && self.author_id ==  user.id
  end

  def touchable_by?(user)
    owned_by?(user) || (user && user.admin?)
  end

  define_index do
    indexes :title
    indexes :text
    set_property :field_weights => { 
      :title => 8,
      :text => 5
    }
    set_property :delta => true
  end


end
