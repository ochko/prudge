# -*- coding: utf-8 -*-
class Solution < ActiveRecord::Base
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

  has_many(:comments,
           :class_name  => 'Comment',
           :as          => 'topic',
           :foreign_key => 'topic_id',
           :dependent   => :destroy,
           :order       => 'created_at DESC')

  scope :passed, where(:state => 'passed')

  def submit!
    Solution.transaction do
      Resque.enqueue(Sandbox, self.id)
      submitted!
    end
  end

  def language
    @language = Language[self[:language]]
  end

  def name
    problem.name
  end

  # For discussion/comment
  def text
    "Хэрэглэгч #{user.login} -ий бодолтод санал/зөвлөгөө/тусламж бичих"
  end

  def log(comment)
    repo = Repo.new(user)
    repo.commit problem_id.to_s, comment
  end

  %w(passed failed defunct locked submitted).each do |stt|
    define_method "#{stt}?" do
      self.state == stt
    end
    define_method "#{stt}!" do
      self.state = stt
      save!
    end
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

  def updated?
    state == 'updated' || submitted?
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
    update_attributes(:state => 'updated',
                      :percent => 0.0,
                      :time => 0.0,
                      :point => 0.0,
                      :junk => nil)
  end

  def summarize!
    return if results.empty?

    self.class.transaction do
      self.state = all_tests_passed? ? 'passed' : 'failed'
      self.percent = passed_ration
      self.point   = points_taken
      self.time    = average_time
      self.solved_in ||= contest.try(:time_passed)
      self.save!
    end
  end

  def attempted!
    attempts = user.solutions.maximum(:attempt_count) || 0
    update_attribute(:attempt_count, attempts + 1)
  end

  def all_tests_passed?
    passed_tests_count == tests_count
  end

  def passed_ration
    passed_tests_count.to_f / tests_count
  end

  def passed_tests_count
    @passed_tests_count ||= results.correct.size
  end

  def tests_count
    @tests_count ||= problem.tests.size
  end

  def points_taken
    passed_ration * problem.point * attempt_bonus
  end

  def average_time
    results.sum(:time) / results.size
  end

  # decreases by 1% per attempt
  def attempt_bonus
    return 0.01 if attempt_count > 100 # unlikely to happen, but possible

    (101 - attempt_count)/100.0
  end
end
