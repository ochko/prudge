class User < ActiveRecord::Base
  DOT_GIT = "#{RAILS_ROOT}/config/dot.git"
  GITIGNORE = "#{RAILS_ROOT}/config/dot.gitignore"

  has_many :solutions
  has_many :completions, :class_name => 'Solution', 
           :conditions => ["correct = ?", true]
  has_many :contests, :through => :solutions, :uniq => true, :order => 'start'
  has_many :tried, :through => :solutions, :uniq => true, :source => :problem
  has_many :solveds, :through => :completions, :uniq => true, :source => :problem
  has_many :problems
  has_many :lessons, :foreign_key => 'author_id'
  has_many :comments, :dependent => :destroy, :order => "created_at DESC"
  
  attr_protected :admin, :judge, :solutions_count, :points

  validates_uniqueness_of :email

  acts_as_authentic do |c|
    c.openid_required_fields = [:nickname, :email]
    c.validate_email_field = false
    c.disable_perishable_token_maintenance = true
  end

  is_gravtastic! :size => 80, :rating => :PG

  after_create :init_repo

  def self.per_page
    100
  end

  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Notifier.deliver_password_reset_instructions(self)  
  end

  def deliver_release_notification!
    reset_perishable_token!  
    Notifier.deliver_release_notification(self)  
  end

  def solutions_dir() "#{Solution::SOLUTIONS_PATH}/#{self.id}" end
  def exe_dir()       "#{solutions_dir}/exe" end

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

  def last_submission_of(problem)
    Solution.find(:first, :conditions => 
                  ["problem_id = ? AND user_id = ?", problem.id, self.id],
                  :order => 'created_at DESC')
  end
  
  def solved(problem)
    Solution.find(:all, :conditions => 
                  ["problem_id = ? AND user_id = ? AND correct = ?",
                   problem.id, self.id, true])
  end

  def currently_commented?
    comments.first && 
      comments.first.created_at > Time.now - 10.seconds
  end
  
  def resum_points!
    update_attribute(:points, solutions.best.sum(:point))
  end

  def solution_uploaded!
    self.update_attribute(:uploaded_at, Time.now)
  end

  def self.resum_points!
    User.all.each do |user|
      user.resum_points!
    end
  end

  def init_repo
    FileUtils.mkdir_p(solutions_dir) unless File.directory?(solutions_dir)
    if system("/usr/bin/git init --quiet --template=#{DOT_GIT} #{solutions_dir}")
      system("/bin/sed -i 's/coder-name/#{self.login}/' #{solutions_dir}/.git/config")
      system("/bin/sed -i 's/coder-email/#{self.email}/' #{solutions_dir}/.git/config")
      FileUtils.cp GITIGNORE, "#{solutions_dir}/.gitignore"
    end
  end

  def import_solutions
    self.solutions.each do |solution|
      solution.insert_to_repo
    end
  end

end
