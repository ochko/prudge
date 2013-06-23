class User < ActiveRecord::Base
  include Gravtastic

  has_many :solutions, :order => 'source_updated_at'
  has_many :completions, :class_name => 'Solution', :conditions => ["state = ?", 'passed']
  has_many :contests, :through => :solutions, :uniq => true, :order => 'start desc'
  has_many :tried, :through => :solutions, :uniq => true, :source => :problem
  has_many :solveds, :through => :completions, :uniq => true, :source => :problem
  has_many :problems
  has_many :posts, :foreign_key => 'author_id'
  has_many :comments, :dependent => :destroy, :order => "created_at DESC"

  scope :moderators, :conditions => ['admin =? or judge =?', true, true]

  attr_protected :admin, :judge, :solutions_count, :points

  validates_uniqueness_of :email

  acts_as_authentic do |c|
    c.validate_email_field = false
    c.disable_perishable_token_maintenance = true
  end

  is_gravtastic! :size => 80, :rating => :PG

  def name
    login
  end

  def owns?(object)
    object.user_id == self.id
  end

  def email_valid?
    email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
  end

  def solved?(problem)
    solutions.where(problem_id: problem.id).passed.count > 0
  end

  def saw!(solution)
    return if owns?(solution)
    solutions.all(:conditions => {:problem_id => solution.problem_id}).each(&:lock!)
  end

  def submitted_at
    solutions.maximum(:source_updated_at)
  end

  def currently_commented?
    comments.first &&
      comments.first.created_at > Time.now - 10.seconds
  end

  def import_solutions
    self.solutions.each do |solution|
      solution.insert_to_repo
    end
  end

  def point_summary
    User.connection.select_value("select sum(point) from (select problem_id, max(point) as point from solutions where user_id = #{id} group by problem_id) maxes").to_f
  end

  def resum_points!
    self.points = point_summary
    save!
  end
end
