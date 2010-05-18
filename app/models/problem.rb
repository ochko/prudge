class Problem < ActiveRecord::Base
  belongs_to :contest
  belongs_to :user

  has_many :solutions
  has_many :tests, :class_name => 'ProblemTest', 
           :order => 'hidden, id',
           :dependent => :destroy
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy

  validates_presence_of :name, :text
  named_scope :commented, :conditions => "comments_count > 0"

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
end
