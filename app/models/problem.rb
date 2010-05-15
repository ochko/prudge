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
  has_many :problem_languages
  has_many :languages, :through => :problem_languages

  validates_presence_of :name, :text

  def owned_by?(someone)
    self.user_id == someone.id
  end

  def test_touched!
    solutions.each { |solution| solution.invalidate!}
  end

  def correct_solutions
    solutions.correct
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

  def update_languages(languages)
    problem_languages.each{ |l| l.destroy }
    if !languages.nil?
    languages.each{ |l_id|
      ProblemLanguage.new({ "problem_id" => id,
                            "language_id" => l_id }).
      save}
    end
  end

  def add_languages(languages)
    if !languages.nil?
      languages.each{ |l_id|
        ProblemLanguage.new({ "problem_id" => id,
                              "language_id" => l_id }).
        save}
    end
  end
end
