class Problem < ActiveRecord::Base
  belongs_to :contest
  belongs_to :user

  has_many :solutions
  has_many :tests, :class_name => 'ProblemTest', 
           :order => 'hidden DESC, id ASC',
           :dependent => :destroy
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy,
           :order => 'created_at DESC'
  has_many :users, :through => :solutions, :uniq => true

  validates_presence_of :name, :text

  named_scope :commented, :conditions => "comments_count > 0"
  named_scope :active, :conditions => ["active_from < ?", Time.now]

  before_save :copy_times

  def owned_by?(someone)
    self.user_id == someone.id
  end

  def test_touched!
    solutions.each { |solution| solution.invalidate!}
  end

  def correct_solutions
    solutions.correct
  end

  def best_solution
    self.solutions.correct(:order => 'time ASC').first
  end

  def corrects_count
    Solution.count_by_sql(["SELECT count(id) FROM solutions where problem_id = ? AND correct = true", self.id])
  end

  def solutions_count
    solutions.count
  end

  def has_permission?(user)
    return false unless user
    return true if user.judge?
    return false unless self.contest.nil?
    return false if self.user_id != user.id
    return true
  end

  def available_to(user)
    return false unless user
    return true if user.judge?
    return true if self.user_id == user.id
    return false if self.contest.nil?
    return true if self.contest.started?
    return false
  end

  def test_addable?(user)
    return false unless user
    return true if user.judge?
    return true if self.user_id == user.id
    return false
  end

  define_index do
    indexes :name
    indexes :text
    indexes :source
    set_property :field_weights => { 
      :name => 10,
      :text => 6,
      :source => 3
    }
    set_property :delta => true
  end

  def collect_cache!
    self.update_attribute(:solved_count, solutions.correct.size)
  end

  def self.collect_caches!
    Problem.
      find(:all,
           :select => "problems.*, count(s.id) as tc, sum(s.correct) as sc",
           :joins => "left join solutions s on problems.id = s.problem_id",
           :group => "problems.id").each do |problem|
      Problem.update_counters(problem.id, 
                              :tried_count => problem.tc.to_i,
                              :solved_count => problem.sc.to_i)
    end
  end

  def check!
    unless self.tests.real.empty?
      self.solutions.each { |solution| solution.check! }
    end
    self.collect_cache!
    #self.users.each{ |u| u.collect_cache! }
  end

  private 
  def copy_times
    if self.changes.has_key?('contest_id')
      self.active_from = self.contest.start
      self.inactive_from = self.contest.end
    end
  end
end
