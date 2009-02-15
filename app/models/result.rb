class Result < ActiveRecord::Base
  belongs_to :solution
  belongs_to :test, :class_name =>'ProblemTest', :foreign_key=>'test_id'
end
