class Result < ActiveRecord::Base
  belongs_to :solution
  belongs_to :test, :class_name =>'ProblemTest', :foreign_key=>'test_id'
  scope :correct, :conditions => { :matched => true }
  scope :incorrect, :conditions => { :matched => false }
  scope :real, :conditions => { :hidden => true }
  
  def before_save
    self.hidden = test.hidden
  end

  def output=(output)
    self.matched = output.correct?
    self.diff = output.diff
    self.output = output.correct? ? nil : output.data
  end  

  def usage=(usage)
    self.execution = usage.state
    self.time   = usage.time
    self.memory = usage.memory
  end

  def output
    matched ? test.output_head : self[:output]
  end

  def failed?
    not correct?
  end

  def normal?
    Usage::State.ok.code == execution
  end

  def correct?
    normal? and matched
  end
end
