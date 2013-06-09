class Result < ActiveRecord::Base
  belongs_to :solution
  belongs_to :test, :class_name =>'ProblemTest', :foreign_key=>'test_id'

  scope :correct, :conditions => { :matched => true }
  scope :incorrect, :conditions => { :matched => false }
  scope :real, :conditions => { :hidden => true }

  has_attached_file :output, :path => ":results_dir/:test_id.output"
  has_attached_file :diff,   :path => ":results_dir/:test_id.diff"

  def result=(output)
    # save output only for non-matched results
    unless self.matched = output.matched?
      self.output = File.open(output.path)
      self.diff   = File.open(output.diff)
    end
  end

  def usage=(usage)
    self.execution = usage.state
    self.time      = usage.time
    self.memory    = usage.memory
  end

  def data
    matched ? test.output_head : File.read(output.path)
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
