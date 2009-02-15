class ProblemTest < ActiveRecord::Base
  belongs_to :problem
  has_many :results, :dependent => :destroy, :foreign_key => 'test_id'
end
