class Lesson < ActiveRecord::Base
  belongs_to :author, :class_name=>'User', :foreign_key => 'author_id'

  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy

  has_many :homeworks, :dependent => :destroy
  has_many :problems, :through => :homeworks

  validates_presence_of     :title, :text

  def self.per_page() 5 end
  
  define_index do
    indexes title
    indexes text
  end
end
