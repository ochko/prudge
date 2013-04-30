class Problem < ActiveRecord::Base
  LEVELS = [1, 2, 4, 8]
  PRICES = { 
    1 => 5, 
    2 => 10, 
    4 => 25, 
    8 => 50 }

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
  validates_inclusion_of :level, :in => LEVELS

  scope :commented, :conditions => ["comments_count > 0 and active_from < ?", Time.now]
  scope :active, :conditions => ["active_from < ?", Time.now]

  def success_rate
    return 0 if tried_count == 0 || solved_count == 0
    solved_count * 100 / tried_count
  end

  def active?
    self.active_from && (self.active_from < Time.now)
  end

  def publicized?
    contest && contest.started?
  end

  def correct_solutions
    solutions.passed
  end

  def corrects_count
    correct_solutions.count
  end

  def solutions_count
    solutions.count
  end

  def check!
    unless self.tests.real.empty?
      self.solutions.each { |solution| solution.check! }
    end
  end

  def resum_counts!
    self.tried_count = solutions_count
    self.solved_count = corrects_count
    self.save!
  end

  def update_active_interval
    return unless contest
    self.active_from = contest.start
    self.inactive_from = contest.end
  end
end
