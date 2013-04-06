# -*- coding: utf-8 -*-
class Solution < ActiveRecord::Base
  include AASM

  aasm :column => 'state' do
    state :updated, :before_enter => :log, :after_enter => :reset!, :initial => true
    state :waiting, :after_enter => :queue
    state :defunct
    state :passed
    state :failed
    state :locked

    event :post do
      transitions :to => :updated, :guard => :first?
    end

    event :repost do
      transitions :to => :updated, :guard => :open?
    end

    event :submit do
      transitions :from => [:updated, :waiting, :errored, :passed, :failed], :to => :waiting
    end

    event :lock! do
      transitions :from => :passed, :to => :locked
    end

    event :errored do
      transitions :from => :waiting, :to => :defunct
    end
  end

  def judged?
    passed? || failed? || defunct?
  end

  belongs_to :contest
  belongs_to :problem, :counter_cache => 'tried_count'
  belongs_to :user, :counter_cache => true
  belongs_to :language
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

  named_scope :for_user, lambda { |user| { :conditions => ['user_id =?', user.id], :include => [:language, :problem], :order => 'created_at desc' } }
  named_scope :valuable, :conditions => 'percent > 0'
  named_scope :fast, :order => 'time ASC, source_updated_at ASC'
  named_scope :for_contest, lambda { |c| { :conditions => ['contest_id =?', c.id] } }

  before_destroy { |solution| solution.cleanup! }

  before_create { |solution| solution.user.solution_uploaded! }

  def self.best
    passed.fast.first
  end

  def queue
    Resque.enqueue(self.class, self.id)
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

  def first?
    user.solutions.all(:conditions => {:problem_id => problem.id}).count == 0
  end

  def owned_by?(someone)
    self.user_id == someone.id
  end

  def open?
    !locked?
  end

  def freezed?
    self.contest && self.contest.finished?
  end

  def apply_contest
    self.contest = nil
    if self.problem.contest && !self.problem.contest.finished?
      self.contest = self.problem.contest
    end
  end

  def code
    File.open(self.source.path, 'r'){ |f| f.read }
  end

  def reset!
    results.clear
    user.refresh_points!
    problem.decrement!(:solved_count) if passed?
    update_attributes(:percent => 0.0,
                      :time    => 0.0,
                      :point   => 0.0,
                      :junk    => nil)
  end

  def summarize!
    summarize_results!
    user.refresh_points!
  end

  def summarize_results!
    unless results.empty?
      ok = results.correct.real.size
      all = problem.tests.real.size

      self.state = (ok == all) ? 'passed' : 'failed'
      self.percent = (ok.to_f / all)
      self.point   = percent * problem.level
      self.time    = (results.sum(:time) / results.size)
      self.solved_in ||= (passed? && contest.try(:time_passed))
      self.save!

      problem.increment!(:solved_count) if passed?
    end
  end
end
