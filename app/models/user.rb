class User < ActiveRecord::Base
  has_many :solutions
  has_many :contests, :through => :solutions, 
           :uniq => true, :order => 'start'
  has_many :problems
  has_many :lessons, :foreign_key => 'author_id'
  has_many :comments, :dependent => :destroy, :order => "created_at DESC"

  acts_as_authentic do |c|
    c.openid_required_fields = [:nickname, :email]
    c.validate_email_field = false
  end

  is_gravtastic! :size => 80, :rating => :PG

  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Notifier.deliver_password_reset_instructions(self)  
  end

  def collect_caches!
    effectives = solutions.best.effective
    unless effectives.empty?
      update_attributes(:solutions_count => effectives.count,
                        :points => effectives.sum(:point),
                        :average => effectives.sum(:time)/effectives.count,
                        :uploaded_at => effectives.maximum(:uploaded_at))
    else
      update_attributes(:solutions_count => solutions.best.count,
                        :points => 0.0,
                        :average => 0.0)
    end
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
end
