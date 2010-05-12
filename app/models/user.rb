class User < ActiveRecord::Base
  has_many :solutions
  has_many :contests, :through => :solutions, 
           :uniq => true, :order => 'start'
  has_many :problems
  has_many :lessons, :foreign_key => 'author_id'

  acts_as_authentic do |c|
    c.openid_required_fields = [:nickname, :email]
  end

  is_gravtastic! :size => 80, :rating => :PG

  def deliver_password_reset_instructions!  
    reset_perishable_token!  
    Notifier.deliver_password_reset_instructions(self)  
  end

  def collect_caches!
    effectives = solutions.best.effective
    unless effectives.empty?
      update_attributes(:solutions_count => solutions.best.count,
                        :points => effectives.sum(:point),
                        :average => effectives.sum(:time)/effectives.count,
                        :uploaded_at => solutions.best.maximum(:uploaded_at))
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

end
