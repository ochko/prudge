class Result < ActiveRecord::Base
  belongs_to :solution
  belongs_to :test, :class_name =>'ProblemTest', :foreign_key=>'test_id'
  named_scope :correct, :conditions => { :matched => true }
  named_scope :incorrect, :conditions => { :matched => false }
  named_scope :real, :conditions => { :hidden => true }
  

  def after_create
    self.diff = self.test.diff(self.solution.output_path)
    self.matched = self.diff.empty?
    self.output = IO.readlines(self.solution.output_path).join
    self.hidden = self.test.hidden
    save!
  end

  def usage=(usage)
    self.status = usage.status
    self.time   = usage.time
    self.memory = usage.memory
  end

  def failed?
    not correct?
  end

  def normal?
    self.status && self.status.strip.eql?('OK')
  end

  def correct?
    normal? and matched
  end

end
