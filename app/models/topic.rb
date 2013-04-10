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
  
  def self.per_page
    20
  end
  
  def name
    title
  end

  def text
    description
  end

  define_index do
    indexes :title
    indexes :description
    set_property :field_weights => { 
      :title => 7,
      :description => 4
    }
    set_property :delta => true
  end

end
