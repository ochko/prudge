class User < ActiveRecord::Base
  include Gravtastic

  has_many :solutions, :order => 'source_updated_at'
  has_many :completions, :class_name => 'Solution', 
           :conditions => ["state = ?", 'passed']
  has_many :contests, :through => :solutions, :uniq => true, :order => 'start'
  has_many :tried, :through => :solutions, :uniq => true, :source => :problem
  has_many :solveds, :through => :completions, :uniq => true, :source => :problem
  has_many :problems
  has_many :lessons, :foreign_key => 'author_id'
  has_many :comments, :dependent => :destroy, :order => "created_at DESC"

  scope :active, :conditions => ['uploaded_at > ?', Time.now - 2.year]
  scope :moderators, :conditions => ['admin =? or judge =?', true, true]
  
  attr_protected :admin, :judge, :solutions_count, :points

  validates_uniqueness_of :email

  acts_as_authentic do |c|
    c.openid_required_fields = [:nickname, :email]
    c.validate_email_field = false
    c.disable_perishable_token_maintenance = true
  end

  is_gravtastic! :size => 80, :rating => :PG

  def self.per_page
    100
  end

  def owns?(object)
    object.user_id == self.id
  end

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)  
  end

  def deliver_release_notification!
    return unless email_valid?
    reset_perishable_token!
    Notifier.deliver_release_notification(self)  
  end

  def deliver_problem_selection!(problem)
    return unless email_valid?
    Notifier.deliver_problem_selection(self, problem.contest, problem)
  end

  def deliver_new_contest(contest)
    return unless notify_new_contests?
    return unless email_valid?
    sleep 180
    Notifier.deliver_new_contest(self, contest)
  end

  def deliver_contest_update(contest)
    return unless email_valid?
    sleep 180
    Notifier.deliver_contest_update(self, contest)
  end

  def email_valid?
    email =~ /^[a-zA-Z][\w\.-]*[a-zA-Z0-9]@[a-zA-Z0-9][\w\.-]*[a-zA-Z0-9]\.[a-zA-Z][a-zA-Z\.]*[a-zA-Z]$/
  end

  def admin?() self.admin == true  end
  def judge?() self.judge == true  end
  
  def level
    Contest::LEVEL_POINTS.keys.sort.each do |l|
      return l if points < Contest::LEVEL_POINTS[l]
    end
  end

  def level_name
    Contest::LEVEL_NAMES[level]
  end
  
  def solved?(problem)
    solutions.passed.count(:conditions => {:problem_id => problem.id}) > 0
  end

  def saw!(solution)
    return if owns?(solution)
    solutions.all(:conditions => {:problem_id => solution.problem_id}).each(&:lock!)
  end

  def currently_commented?
    comments.first && 
      comments.first.created_at > Time.now - 10.seconds
  end
  
  def solution_uploaded!
    self.update_attribute(:uploaded_at, Time.now)
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
