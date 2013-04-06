class ProblemTest < ActiveRecord::Base
  named_scope :real, :conditions => { :hidden => true }
  
  belongs_to :problem, :counter_cache => 'tests_count'

  has_many :results, :dependent => :destroy, :foreign_key => 'test_id'

  has_attached_file :input,  :path => ":test_root/input/:problem_id/:id.in"
  has_attached_file :output, :path => ":test_root/output/:problem_id/:id.out"

  validates_attachment_presence :input
  validates_attachment_presence :output
end
