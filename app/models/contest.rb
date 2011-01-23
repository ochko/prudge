# -*- coding: utf-8 -*-
class Contest < ActiveRecord::Base
  LEVEL_NAMES = { 0 => 'Бүгд', 
    1 => 'Сонирхогч', 
    2 => 'Анхан шат', 
    4 => 'Дунд шат', 
    8 => 'Дээд шат' }

  LEVEL_POINTS = { 0 => 0, 
    1 => 50, 
    2 => 150, 
    4 => 300, 
    8 => 1000 }

  has_many :problems
  has_many :solutions
  has_many :users, :through => :solutions,
      :select => "users.login, users.id, sum(solutions.point) as point, sum(solutions.solved_in) as time",
      :group => 'user_id', :order => "point DESC, time ASC"
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy,
           :order => 'created_at DESC'

  validates_presence_of :name, :start, :end

  validate do |contest|
    contest.errors.add_to_base("Эхлэх дуусах цаг буруу") if 
      contest.start > contest.end
  end

  before_save :update_problems

  named_scope :current, :conditions => "end > NOW()", :order => "start ASC"
  named_scope :finished,:conditions => "end < NOW()", :order => "end DESC"
  named_scope :pending, :conditions => "end >= NOW()"
  named_scope :commented, :conditions => "comments_count > 0"

  def standings
    num, point, time = 0, 0.0, 0.0
    numbers = [] 
    standers = []
    for user in self.users
      if (point != user.point) || (user.time.to_f - time.to_f > 0.1)
        point = user.point
        num += 1
      end
      time = user.time
      numbers << num
      standers << user
    end
    [numbers, standers]
  end

  def open?
    self.level == 0
  end

  def finished?
    self.end < Time.now
  end
  
  def started?
    self.start < Time.now
  end

  def level_name
    LEVEL_NAMES[level]
  end

  define_index do
    indexes :name
    indexes :description
    set_property :field_weights => { 
      :name => 9,
      :description => 5
    }
    set_property :delta => true
  end

  def text
    description
  end

  private
  def update_problems
    if self.changes.has_key?('start') || self.changes.has_key?('end')
      self.problems.each do |problem|
        problem.update_attributes!(:active_from => self.start,
                                   :inactive_from => self.end)
      end
    end
  end
end
