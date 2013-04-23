# -*- coding: utf-8 -*-
class Solution < ActiveRecord::Base
  include AASM

  belongs_to :contest
  belongs_to :problem, :counter_cache => 'tried_count'
  belongs_to :user, :counter_cache => true
  has_many :results, :order => 'hidden ASC, matched DESC', :dependent => :destroy
  has_many :tests, :through => :problem, :order => 'hidden, id'

  has_attached_file :source,
                    :url => "/users/:user_id/solutions/:id.code",
                    :path => ":repo_root/:user_id/:problem_id/:id.code"

  validates_attachment_presence :source
  validates_attachment_size :source, :less_than => 64.kilobytes

  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy,
           :order => 'created_at DESC'

  scope :valuable, :conditions => 'percent > 0'
  scope :fast, :order => 'time ASC, source_updated_at ASC'
  scope :for_contest, lambda { |c| { :conditions => ['contest_id =?', c.id] } }

  aasm :column => 'state' do
    state :updated, :before_enter => :log, :after_enter => :reset!, :initial => true
    state :waiting, :after_enter => :queue
    state :defunct
    state :passed
    state :failed
    state :locked

    event :post do
      transitions :to => :updated
    end

    event :submit do
      transitions :from => [:updated, :waiting, :errored, :passed, :failed], :to => :waiting
    end

    event :lock do
      transitions :to => :locked
    end

    event :errored do
      transitions :from => :waiting, :to => :defunct
    end
  end

  def self.best
    passed.fast.first
  end

  def queue
    Resque.enqueue(self.class, self.id)
  end

  def language
    @language = Language[self[:language]]
  end

  # Resque invokes it
  def self.perform(id)
    sandbox = Sandbox.new(find(id))
    sandbox.run
  end

  # For discussion/comment
  def name() problem.name end
  def text() "Хэрэглэгч #{user.login} -ий бодолтод санал/зөвлөгөө/тусламж бичих" end

  def log
    repo = Repo.new(user)
    repo.commit problem_id.to_s, "Updated solution for #{problem_id}"
  end

  def judged?
    passed? || failed? || defunct? || locked?
  end

  def open?
    !(locked? || freezed?)
  end

  def freezed?
    contest && contest.finished?
  end

  def competing?
    contest && !contest.finished?
  end

  def fresh?
    previous.nil? || (previous.freezed? && !previous.locked?)
  end

  def previous
    @previous ||= user.solutions.last(:conditions => {:problem_id => problem_id}, :order => 'created_at')
  end

  def problem_id=(id)
    problem = Problem.find(id)
    if new_record?
      self.contest = nil
      if problem.contest && !problem.contest.finished?
        self.contest = problem.contest
      end
    end
    self.problem = problem
  end

  def code
    File.open(self.source.path, 'r'){ |f| f.read }
  end

  def reset!
    results.clear
    update_attributes(:percent => 0.0, :time => 0.0, :point => 0.0, :junk => nil)
  end

  def summarize!
    return if results.empty?

    ok = results.correct.real.size
    all = problem.tests.real.size

    self.class.transaction do
      self.state = (ok == all) ? 'passed' : 'failed'
      self.percent = (ok.to_f / all)
      self.point   = percent * problem.level
      self.time    = average_time
      self.solved_in ||= solution.contest.try(:time_passed)
      self.save!
    end
  end

  def average_time
    results.sum(:time) / results.size
  end
end
