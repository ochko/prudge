# -*- coding: utf-8 -*-
class Contest < ActiveRecord::Base
  LEVEL_NAMES = { 0 => 'Бүгд', 
    1 => 'Явган', 
    2 => 'Дугуй', 
    4 => 'Мотоцикл', 
    8 => 'Машин',
    16=> 'Галт тэрэг',
    32=> 'Усан онгоц',
    64=> 'Нисдэг тэрэг',
    128=> 'Онгоц'}

  LEVEL_POINTS = { 0 => 0, 
    1 => 50, 
    2 => 150, 
    4 => 300, 
    8 => 450,
    16=> 600,
    32=> 750,
    64=> 900,
    128=> 1150}

  has_many :problems
  has_many :solutions

  has_many :users, :through => :solutions,
      :select => "users.login, users.id, sum(solutions.point) as point, sum(solutions.solved_in) as time",
      :group => 'users.login, users.id', :order => "point DESC, time ASC"

  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy,
           :order => 'created_at DESC'

  has_many :contributors, :through => :problems, :source => :user, :uniq => true

  has_and_belongs_to_many :watchers, :class_name => 'User'

  validates_presence_of :name, :start, :end

  validate do |contest|
    contest.errors.add_to_base("Эхлэх дуусах цаг буруу") if contest.start > contest.end
  end

  scope :current, :conditions => "end > NOW()", :order => "start ASC"
  scope :finished,:conditions => "end < NOW()", :order => "end DESC"
  scope :pending, :conditions => "end >= NOW()"

  def standings
    num, point, time = 0, 0.0, 0.0
    numbers = [] 
    standers = []
    users.each do |user|
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

  def finished?
    self.end < Time.now
  end
  
  def started?
    self.start < Time.now
  end

  def continuing?
    started? && !finished?
  end

  def openfor?(user)
    continuing? && competable?(user) && invites?(user)
  end

  def competable?(user)
    level == 0 || user.level <= level
  end

  def invites?(user)
    !private? || contributors.include?(user)
  end

  def time_passed
    return nil unless started?
    Time.now - start
  end

  def level_name
    LEVEL_NAMES[level]
  end

  def text
    description
  end

  def time_changed?
    (changed & %w[start end]).present?
  end
end
