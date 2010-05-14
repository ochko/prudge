class Lesson < ActiveRecord::Base
  belongs_to :author, :class_name=>'User', :foreign_key => 'author_id'

  has_many :attachments,
           :as => 'attachable',
           :class_name => 'ActiveRecord::Attachment',
           :foreign_key => 'attachable_id',
           :dependent => :destroy

  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy

  has_many :homeworks, :dependent => :destroy
  has_many :problems, :through => :homeworks

  validates_presence_of     :title, :text

  def self.per_page() 5 end

  def has_permission?(user)
    return false if user == :false or user.nil?
    if self.author_id == user.id
      return true
    end
    return false
  end

  def available_to(user)
    return true
  end
  
  define_index do
    indexes title
    indexes text
  end
end
