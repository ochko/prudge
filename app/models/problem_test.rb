class ProblemTest < ActiveRecord::Base
  scope :real, :conditions => { :hidden => true }

  belongs_to :problem, :counter_cache => 'tests_count'

  has_many :results, :dependent => :destroy, :foreign_key => 'test_id'

  has_attached_file :input,  :path => ":test_root/input/:problem_id/:id.in"
  has_attached_file :output, :path => ":test_root/output/:problem_id/:id.out"

  validates_attachment_presence :input
  validates_attachment_presence :output

  def input_head(size=1.kilobytes)
    read_head input.path, size
  end

  def output_head(size=1.kilobytes)
    read_head output.path, size
  end

  def visible?
    !hidden
  end

  private

  def read_head(path, size)
    File.open(path, 'r') do |file|
      file.read(size).tap do |head|
        head << "..." if file.size > size
      end
    end
  end
end
