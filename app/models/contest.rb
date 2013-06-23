# -*- coding: utf-8 -*-
class Contest < ActiveRecord::Base
  has_many :problems
  has_many :solutions
  has_many :participants

  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy,
           :order => 'created_at DESC'

  has_and_belongs_to_many :watchers, :class_name => 'User'

  validates_presence_of :name, :start, :end

  validate do |contest|
    contest.errors.add_to_base("Эхлэх дуусах цаг буруу") if contest.start > contest.end
  end

  scope :current, :conditions => "end > NOW()", :order => "start ASC"
  scope :finished,:conditions => "end < NOW()", :order => "end DESC"
  scope :pending, :conditions => "end >= NOW()"

  def rank!
    return unless continuing?

    fetched = participants.grouped

    Participant.transaction do
      solutions.select("user_id, sum(point) as point").group(:user_id).order('point DESC').reduce(0) do |rank, solution|
        participant = fetched[solution.user_id] || participants.build(:user_id => solution.user_id)
        participant.rank = (rank += 1)
        participant.points = solution.point
        participant.save!
        rank
      end
    end
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

  def time_passed
    return nil unless started?
    Time.now - start
  end

  def text
    description
  end

  def time_changed?
    (changed & %w[start end]).present?
  end
end
