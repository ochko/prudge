class Problem < ActiveRecord::Base
  belongs_to :contest
  belongs_to :user
  belongs_to :problem_type
  has_many :solutions
  has_many :problem_tests, :order => 'hidden, id',
           :dependent => :destroy
  has_many :attachments,
           :as => 'attachable',
           :class_name => 'Attachment',
           :foreign_key => 'attachable_id',
           :dependent => :destroy
  has_many :comments,
           :as => 'topic',
           :class_name => 'Comment',
           :foreign_key => 'topic_id',
           :dependent => :destroy
  has_many :problem_languages
  has_many :languages, :through => :problem_languages

  validates_presence_of :name, :text

  def correct_solutions
    solutions.select{ |s| s.correct }
  end

  def has_permission?(user)
    return false if user == :false or user.nil?

    if user.
        roles.map{ |role| role.title.downcase}.
        include?('judge')
      return true
    end

    if !self.contest.nil?
      return false
    end

    if self.user_id != user.id
      return false
    end

    return true
  end

  def available_to(user)
    id = 0
    if user != :false and !user.nil?
      id = user.id
      if user.
          roles.map{ |role| role.title.downcase}.
          include?('judge')
        return true
      end
    end

    if self.user_id == id
      return true
    end

    if self.contest.nil?
      return false
    end

    if self.contest.start < Time.now()
      return true
    end

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
