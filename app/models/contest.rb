class Contest < ActiveRecord::Base
  belongs_to :contest_type, :foreign_key => 'type_id'
  belongs_to :prize
  belongs_to :sponsor
  has_many :problems
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy

  validates_presence_of :name
  acts_as_textiled :description
end
